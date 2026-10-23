# Applications that are deliberately not installed, by shadowing their nixpkgs
# attribute with an empty package.
#
# This is a blunt instrument and that is a real cost. It shadows the attribute
# for everything in this machine, not only for the one list that wanted the app
# gone. It is here because for these there is no narrower route:
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
# The risk this accepts: anything else that wants one of these as a working
# package gets an empty directory instead. foot and evince are leaf desktop
# applications with no library consumers, so that is a risk taken knowingly. If
# one ever needs to come back, delete its entry here rather than fighting this.
#
# The evince entry shows that assumption being wrong, and the sushi override
# below is the repair. Prefer to read that before adding a fourth name here.
#
# chromium used to be the one omission here, and for a hard reason: nixpkgs
# builds Electron out of it (pkgs/development/tools/electron/common.nix does
# `chromium.override { ... }`), and Heroic and Bitwarden Desktop were both
# Electron apps installed from nixpkgs, so shadowing chromium made the whole
# system fail to evaluate.
#
# They are Flatpaks now -- Heroic, Bitwarden and draw.io all live in
# hosts/nixos/nixarchy/services.nix -- so Electron has no consumer left in this
# closure. What still needs a browser engine is mermaid-cli: its wrapper sets
# PUPPETEER_EXECUTABLE_PATH from the `chromium` argument, and mmdc is what
# md-export and diagram.nvim render mermaid with.
#
# So `chromium` here is a shim, not the nixpkgs package: a two-line script that
# runs the org.chromium.Chromium Flatpak. mermaid-cli gets that shim plus a
# Puppeteer config that makes it talk to the Flatpak over a TCP DevTools port
# (`pipe: false`), because the Flatpak sandbox cannot receive the file
# descriptors Puppeteer's default pipe transport uses, and grants the sandbox
# read-only /nix/store so Chromium can load mermaid-cli's own index.html. The
# Flatpak override that grants that is in services.nix, next to the package.
#
# Net effect: no nixpkgs Chromium is built or installed, the browser comes from
# Flathub, and an update never compiles Chromium again.
{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (
      final: prev: {
        # Browser shim: the nixpkgs Chromium attribute now points at the
        # Flathub app, so nothing in the closure builds or carries Chromium
        # itself. Both names are provided because omarchy's scripts and
        # desktop-file code use both. See the header for the mermaid detail.
        chromium =
          let
            shim = prev.runCommand "chromium-flatpak" { } ''
              mkdir -p $out/bin
              cat > $out/bin/chromium <<'EOF'
              #!/bin/sh
              exec ${prev.flatpak}/bin/flatpak run --command=chromium org.chromium.Chromium "$@"
              EOF
              chmod +x $out/bin/chromium
              ln -s chromium $out/bin/chromium-browser
            '';
          in
          shim
          // {
            meta = (shim.meta or { }) // {
              mainProgram = "chromium";
              description = "Chromium, run from its Flathub Flatpak";
            };
          };

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

        # mermaid-cli builds its wrapper with `lib.getExe chromium`, so it gets
        # the shim above, and the appended -p points every mmdc invocation at
        # the Puppeteer config that switches the transport to a TCP port and
        # grants the flags the Flatpak needs. Without this the wrapper defaults
        # to Puppeteer's pipe transport, which does not cross the Flatpak
        # sandbox boundary.
        mermaid-cli =
          let
            puppeteerConfig = prev.writeText "mmdc-puppeteer.json" (
              builtins.toJSON {
                executablePath = "${final.chromium}/bin/chromium";
                pipe = false;
                args = [
                  "--no-sandbox"
                  "--disable-gpu"
                ];
              }
            );
          in
          (prev.mermaid-cli.override { chromium = final.chromium; }).overrideAttrs (old: {
            postFixup = (old.postFixup or "") + ''
              wrapProgram $out/bin/mmdc --add-flags "-p ${puppeteerConfig}"
            '';
          });
      }
    )
  ];
}
