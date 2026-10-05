#!/usr/bin/env python3
"""
Give a lone window the full width of its workspace, and shrink it back to half
when other windows join it.

Niri has no setting for this. Its scrolling layout resolves a column width as
(working_width - gaps) * proportion, with no special case for a column that is
alone on the workspace, so a single window sits at default-column-width (50% by
default) forever. `window-rule { open-maximized true }` does not help either: a
maximized column keeps its full width when a peer opens beside it, so the two
overlap instead of splitting.

This daemon restores the behaviour Hyprland's scrolling layout had natively,
which is what the old Omarchy desktop did with `scrolling:column_width 0.5`.

It only ever acts when the number of windows on a workspace changes. A width you
set by hand is left alone until the next window opens or closes on that
workspace, so this never fights you for control.

Widths are applied with Action::SetWindowWidth addressed by window id, which
targets a specific column without moving focus. Action::SetColumnWidth would
have been the obvious call, but it takes no id and only ever affects the focused
column -- reaching the others through it would mean stealing focus repeatedly.
"""

import json
import os
import socket
import sys
import time

SOLO_PROPORTION = 100.0
SHARED_PROPORTION = 50.0

# Niri maps one window to one column, but a column can hold several windows as
# tabs. Counting windows would then mistake a two-tab column for two columns and
# ask for a split that should not happen, so columns are counted from each
# window's position instead.
RETRY_DELAYS = (0.15, 0.35, 0.75, 1.5)


def log(message):
    print(f"[niri-solo-width] {message}", file=sys.stderr, flush=True)


class Niri:
    def __init__(self, path):
        self.path = path

    def _connect(self):
        sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        sock.connect(self.path)
        return sock

    def call(self, request):
        """Send one request, read one reply. Returns the decoded reply."""
        sock = self._connect()
        try:
            sock.sendall((json.dumps(request) + "\n").encode())
            sock.settimeout(5)
            buf = b""
            while not buf.endswith(b"\n"):
                chunk = sock.recv(4096)
                if not chunk:
                    break
                buf += chunk
            return json.loads(buf.decode())
        finally:
            sock.close()

    def events(self):
        """Yield (event_name, payload) forever. Reconnects if niri restarts."""
        while True:
            try:
                sock = self._connect()
            except OSError as err:
                log(f"cannot reach niri at {self.path}: {err}")
                time.sleep(2)
                continue

            log("connected to niri event stream")
            sock_file = sock.makefile("r", encoding="utf-8", errors="replace")
            try:
                # Connecting is not enough to get events: niri only starts
                # streaming once asked, so the request has to go out first.
                sock.sendall(b'{"EventStream": null}\n')

                # The next line is the reply to that request, {"Ok":"Handled"}.
                # It must be consumed but not treated as an event: the CLI's
                # "Started reading events." message is printed by `niri msg`, not
                # sent over the socket, so matching on a fixed greeting instead
                # would silently swallow the first real event.
                greeting = sock_file.readline()
                if not greeting:
                    raise ConnectionError("niri closed the stream immediately")
                for line in sock_file:
                    line = line.strip()
                    if not line:
                        continue
                    try:
                        event = json.loads(line)
                    except json.JSONDecodeError:
                        continue
                    name, payload = next(iter(event.items()))
                    yield name, payload
            except (OSError, ConnectionError) as err:
                log(f"event stream ended: {err}")
            finally:
                sock.close()
            time.sleep(2)

    def windows(self):
        # The reply nests the list under "Windows", matching the request name.
        reply = self.call("Windows")
        return reply.get("Ok", {}).get("Windows", [])

    def set_width(self, window_id, proportion):
        reply = self.call(
            {
                "Action": {
                    "SetWindowWidth": {
                        "id": window_id,
                        "change": {"SetProportion": proportion},
                    }
                }
            }
        )
        return "Ok" in reply


def columns_by_workspace(windows):
    """
    Map workspace id -> {column index: representative window id}.

    Windows in the same column share a column index, so the first window of each
    column represents it. Floating windows are skipped: they have no column to
    size, and a floating window must not stop a tiled one from going full width.
    """
    columns = {}
    for window in windows:
        if window.get("is_floating") or window.get("workspace_id") is None:
            continue
        layout = window.get("layout") or {}
        position = layout.get("pos_in_scrolling_layout")
        if not position or len(position) < 1:
            continue
        workspace = window["workspace_id"]
        column_index = position[0]
        columns.setdefault(workspace, {}).setdefault(column_index, window["id"])
    return {ws: by_index for ws, by_index in columns.items()}


def adjust(niri, windows, previous):
    """
    Apply solo/shared widths, but only to workspaces whose column count changed.

    Keying the decision on the column count per workspace is what keeps this from
    fighting the user. Windows are only touched on the transition:

        0 -> 1   the new window goes full width
        1 -> n   it shrinks back to a share
        n -> 1   the survivor expands again
        n -> m   nothing, an added window only ever opens at the shared width

    A width set by hand therefore survives until the count on that same workspace
    actually changes. It also means opening a window on one workspace never
    touches another.

    A workspace is left alone when its column count is unchanged, even if the
    windows in it were replaced, and `previous` is updated either way so the
    comparison stays honest.
    """
    columns = columns_by_workspace(windows)
    changed = False

    for workspace, by_index in columns.items():
        count = len(by_index)
        if previous.get(workspace) == count:
            continue
        proportion = SOLO_PROPORTION if count == 1 else SHARED_PROPORTION
        for window_id in by_index.values():
            if niri.set_width(window_id, proportion):
                changed = True
                log(f"workspace {workspace}: {count} column(s), window {window_id} -> {proportion:g}%")
        previous[workspace] = count

    # Workspaces that no longer exist still need their count forgotten, so that
    # recreating one later is not mistaken for an unchanged workspace.
    for workspace in list(previous):
        if workspace not in columns:
            del previous[workspace]

    return changed


def reconcile(niri, previous, attempts=1):
    """
    Read the window list and apply widths, retrying while it keeps changing.

    A window that is still mapping reports a layout without a position, and
    opening several at once produces several events in quick succession, so a
    single pass can read a half-built layout. Re-reading until two consecutive
    passes agree settles it without a timer.
    """
    snapshot = None
    for attempt in range(attempts):
        windows = niri.windows()
        fingerprint = json.dumps(
            [(w["id"], (w.get("layout") or {}).get("pos_in_scrolling_layout")) for w in windows],
            sort_keys=True,
        )
        adjust(niri, windows, previous)
        if fingerprint == snapshot:
            return True
        snapshot = fingerprint
        if attempt + 1 < attempts:
            time.sleep(RETRY_DELAYS[min(attempt, len(RETRY_DELAYS) - 1)])
    return False


def main():
    path = os.environ.get("NIRI_SOCKET")
    if not path:
        log("NIRI_SOCKET is not set; is this running inside an niri session?")
        return 1

    niri = Niri(path)

    # Column counts seen so far, per workspace. Seeded as unknown so the first
    # pass sizes whatever was already open before this daemon started.
    previous = {}

    reconcile(niri, previous, attempts=len(RETRY_DELAYS) + 1)

    for name, _payload in niri.events():
        # Only window count changes are this daemon's business. Focus, urgency,
        # title and layout changes are deliberately ignored: reacting to them
        # would undo a width the user set by hand. adjust() then narrows this
        # further by skipping any workspace whose column count is unchanged.
        if name not in ("WindowOpenedOrChanged", "WindowClosed", "WindowsChanged"):
            continue
        reconcile(niri, previous, attempts=len(RETRY_DELAYS) + 1)

    return 0


if __name__ == "__main__":
    sys.exit(main())