# Applications that are deliberately not installed, by shadowing their nixpkgs
# attribute with an empty package.
#
# This is a blunt instrument and that is a real cost. It shadows the attribute
# for everything in this machine, not only for the one list that wanted the app
# gone. It is here because for these two there is no narrower route:
#
#   - They are not nixarchy `preinstalls`, so `preinstallsExclude` cannot name
#     them. That option is the right answer for libreoffice, obs-studio,
#     moonlight-qt and kdenlive, and those are excluded there instead.
#   - `programs.nixarchy.package` cannot filter them either. `runtimeDeps` is a
#     `let` binding inside nixarchy's pkgs/omarchy/default.nix, not a function
#     argument, so `.override { runtimeDeps = ...; }` is rejected outright.
#   - `environment.systemPackages = lib.mkForce (builtins.filter ... config
#     .environment.systemPackages)` is the idiom that looks right and is not:
#     the self-reference is infinite recursion. Measured, not assumed.
#
# What happens mechanically: nixarchy's runtimeDeps holds these as ordinary `pkgs`
# references, so with the attribute shadowed every reference -- including
# nixarchy's own -- resolves to the empty package. It contributes no bin/, so
# nothing is symlinked into /run/current-system/sw/bin and no desktop entry is
# installed. The real packages drop out of the system closure.
#
# The risk this accepts: anything else that wants one of these two as a working
# package gets an empty directory instead. Both are leaf desktop applications
# with no library consumers, so that is a risk taken knowingly. If one ever needs
# to come back, delete its entry here rather than fighting this.
#
# The evince entry shows that assumption being wrong, and the sushi override
# below is the repair. Prefer to read that before adding a fourth name here.
#
# chromium is the case where that cost is NOT worth paying, which is why it is
# the one omission here. It is in the same nixarchy runtimeDeps list and would
# shadow exactly as cleanly as these two, but nixpkgs builds Electron out of it:
# pkgs/development/tools/electron/common.nix does `chromium.override { ... }`.
# Heroic and Bitwarden Desktop are both enabled in ~/.config/nixarchy/apps.nix
# and both are Electron apps, so shadowing chromium does not remove a browser --
# it makes the whole system fail to evaluate. Verified, not inferred:
# `heroic-2.22.3` and `bitwarden-desktop-2026.9.0` both reference
# electron-43.6.0 in the current closure.
#
# So chromium stays installed as an Electron build input. The cost is disk, and a
# `chromium` binary that nothing launches. Removing it means giving up Heroic and
# Bitwarden, which is a worse trade than the disk.
{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (
      final: prev: {
        # Terminal. Replaced by ghostty, which was already nixarchy's terminal.
        # ~/.config/xdg-terminals.list points xdg-terminal-exec there, because
        # foot.desktop was the only entry in xdg-terminal-exec's preference list
        # and without that file "Open Terminal" would have nothing to launch.
        foot = prev.runCommand "foot-not-installed" { } ''
          mkdir -p $out
          echo "foot is deliberately not installed on this machine; the terminal is ghostty." > $out/README
        '';

        # PDF viewer. Replaced by zathura, kept in ./default.nix.
        evince = prev.runCommand "evince-not-installed" { } ''
          mkdir -p $out
          echo "evince is deliberately not installed on this machine; the PDF viewer is zathura." > $out/README
        '';

        # evince is not a leaf package, and this is the cost of shadowing it.
        # sushi -- the handler behind Space-to-preview in Nautilus, which is
        # installed and wanted -- links libevince, and nixpkgs' pkgs set is a
        # fixed point, so shadowing `evince` silently changed sushi's own
        # `evince` argument and its build died on "Dependency evince-document-3.0
        # not found". Rebuilt here against the real library, so the application
        # stays uninstalled while its libraries remain available to the one
        # consumer that genuinely needs them. Verified to be the only such
        # consumer: nothing but sushi references the real evince in the closure.
        sushi = prev.sushi.override { evince = prev.evince; };
      }
    )
  ];
}
