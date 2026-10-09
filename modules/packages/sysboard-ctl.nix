# sysboard-ctl: a supervisor that keeps the sysboard on-screen keyboard
# running only while no real keyboard is attached.
#
# sysboard itself already knows *when* to be visible. The compositor tells it,
# over zwp_input_method_v2, when a text field gains focus (activate) and loses
# it (deactivate), and it shows and hides accordingly -- verified on this
# machine under niri. What sysboard cannot know is whether the user is sitting
# at a keyboard already. That decision is not expressible in sysboard's own
# configuration, and its signal protocol (activate/deactivate) can only express
# "show now" or "hide now", not "stay hidden until a keyboard goes away". So it
# is made here, by controlling whether sysboard runs at all:
#
#   a keyboard is attached -> sysboard is not running, and cannot show
#   no keyboard attached   -> sysboard runs and follows focus as it always does
#
# This is preferred over sysboard's own toggle-on-swipe behaviour, where the
# keyboard is only visible after a deliberate gesture.
{ writeShellApplication, systemd, coreutils, sysboard }:

writeShellApplication {
  name = "sysboard-ctl";

  # udevadm to classify /dev/input nodes, sleep/printf from coreutils. The
  # sysboard binary is addressed by its store path inside the script, not via
  # PATH, so it does not need to be in runtimeInputs.
  runtimeInputs = [ systemd coreutils ];

  text = ''
    set -euo pipefail

    SYSBOARD=${sysboard}/bin/sysboard
    POLL=1
    SETTLE=0.3

    sysboard_pid=""

    # True when at least one keyboard that should suppress the OSK is present.
    #
    # ID_INPUT_KEYBOARD=1 is udev's own classification, and it is deliberately
    # narrow: the system's power button, lid switch, video bus and WMI hotkeys
    # all register a `kbd` input handler and appear as /dev/input/event* nodes,
    # but none of them carry the property. Only the AT keyboard and the
    # Bluetooth Keychron do. So this is the exact set wanted, with one
    # correction:
    #
    # The i8042 PS/2 controller is registered at every boot on this machine
    # whether or not a keyboard is plugged into it, and udev marks that one
    # ID_INPUT_KEYBOARD=1 with ID_BUS=i8042. Counting it would mean the OSK
    # could never appear at all, so ID_BUS=i8042 is skipped. That is the
    # "ignore the built-in PS/2 keyboard" choice, made explicit.
    keyboard_connected() {
      local dev props
      for dev in /dev/input/event*; do
        [ -e "$dev" ] || continue
        props=$(udevadm info --query=property --name="$dev" 2>/dev/null) || continue
        case "$props" in *ID_INPUT_KEYBOARD=1*) ;; *) continue ;; esac
        case "$props" in *ID_BUS=i8042*) continue ;; esac
        return 0
      done
      return 1
    }

    sysboard_running() {
      [ -n "$sysboard_pid" ] && kill -0 "$sysboard_pid" 2>/dev/null
    }

    start_sysboard() {
      sysboard_running && return 0
      "$SYSBOARD" &
      sysboard_pid=$!
    }

    stop_sysboard() {
      sysboard_running || { sysboard_pid=""; return 0; }
      kill "$sysboard_pid" 2>/dev/null || true
      wait "$sysboard_pid" 2>/dev/null || true
      sysboard_pid=""
    }

    cleanup() {
      stop_sysboard
    }
    trap cleanup TERM INT HUP EXIT

    # The device listing is the trigger: /dev/input/event* changes exactly when
    # a device is added or removed, and a shell glob costs no process, so the
    # expensive part -- one udevadm call per device -- runs only on a change or
    # when reconciling. A hotplug is picked up within POLL seconds, well under
    # the time it takes to reach for the next text field.
    listing=$(printf '%s\n' /dev/input/event*)
    if keyboard_connected; then desired=present; else desired=absent; fi

    while true; do
      current=$(printf '%s\n' /dev/input/event*)
      if [ "$current" != "$listing" ]; then
        # A composite device (a keyboard that also reports as a pointer, or a
        # receiver that enumerates two nodes) publishes its nodes one after
        # another. Let the listing settle before classifying, so a keyboard is
        # not missed because only its first node existed yet.
        sleep "$SETTLE"
        settled=$(printf '%s\n' /dev/input/event*)
        if [ "$settled" != "$current" ]; then
          sleep "$POLL"
          continue
        fi
        listing=$current
        if keyboard_connected; then desired=present; else desired=absent; fi
      fi

      # Reconcile on every tick, so a sysboard that exited is restarted and one
      # that is running while a keyboard is present is stopped.
      if [ "$desired" = present ]; then
        stop_sysboard
      else
        start_sysboard
      fi

      sleep "$POLL"
    done
  '';

  meta.description = "Run sysboard only while no real keyboard is attached";
}
