# Home Manager for hosts/nixos: dotfiles wiring.
#
# Nixarchy's own home-manager module is imported by the flake as a sharedModule.
# This file only adds what nixarchy does not provide:
#
#   - the dotfiles, as store symlinks into the vendored ./dotfiles tree
#   - fish as the login shell
#   - neovim pointing at the LazyVim checkout, rather than at the old repo's
#     half-finished nvf port
#
# Nothing here redefines a nixarchy option. programs.nixarchy.neovim is set to
# "adopt" in hosts/nixos/configuration.nix so that nixarchy reports the gruvbox
# collision instead of silently keeping its own theme.
{ config, lib, pkgs, ... }:

let
  dotfiles = ../../dotfiles;

  # Where this configuration must live on disk for the out-of-store symlinks
  # below to resolve.
  #
  # It is an absolute path rather than something derived, because Home Manager
  # builds the link at evaluation time and needs the FINAL location, not the
  # checkout being evaluated. While this branch is being built from
  # /home/mark/nix-config the symlinks are dangling -- harmless, since nothing
  # is activated until the repository is in place.
  #
  # This must agree with programs.nixarchy.flake in hosts/nixos/default.nix,
  # which is where nixos-rebuild and nh os switch will look for this flake.
  repoDir = "/etc/nixos";
in
{
  # ---------------------------------------------------------------- Imports
  #
  # Exactly one file, and not the tree it lives in.
  #
  # homeManagerModules/default.nix exists and reads like it is wired, but
  # nothing imports it: not this file, not flake.nix, not hosts/nixos/default.nix.
  # home.nix reaches ../../dotfiles directly instead. So the whole of
  # homeManagerModules/ is currently inert -- its home.packages (OnlyOffice,
  # Zen Browser, Blender, ...), its fish and neovim wiring, the fontconfig
  # monospace alias in core/xdg-overrides.nix. All of it is dead code.
  #
  # That is worth knowing and it is why this is not
  #
  #   imports = [ ../../homeManagerModules ];
  #
  # Importing the tree would switch on roughly forty packages and a dozen dotfile
  # directories that nothing has been running against, on a desktop that works.
  # Several of them collide with what is live -- desktop-apps.nix installs
  # onlyoffice-desktopeditors, which nixarchy-apps.nix already installs
  # system-wide -- and the fish/ghostty entries in there overlap home.nix's own,
  # which is exactly the collision home.nix documents at length for
  # ~/.config/fish. Reviving the tree is its own piece of work.
  #
  # core/fonts.nix is imported on its own because it has to be live: OnlyOffice
  # builds its font list by walking directories and ignoring fontconfig, so this
  # file is the only thing that makes Inter and the rest of the list appear in
  # it. Nothing else in homeManagerModules/ is needed for that.
  imports = [ ../../homeManagerModules/core/fonts.nix ];

  # ---------------------------------------------------------------- Identity
  #
  # home.stateVersion was genuinely missing, not merely inherited: nixarchy's
  # home module does not set it, so without this the first evaluation fails
  # with "the option home.stateVersion was accessed but has no value defined",
  # raised from inside swaylock.nix via home-manager.users.mark.assertions.
  #
  # "25.11" is the live system's value and the value the running Home Manager
  # store paths were generated with. Setting it to anything else would tell HM
  # that every existing file is from a newer release than it knows about, and
  # it would rewrite the whole profile on the first activation. Do not "fix" the
  # mismatch with system.stateVersion = "26.05" -- the two are allowed to
  # differ, and on this machine they do.
  home.username = "mark";
  home.homeDirectory = "/home/mark";
  home.stateVersion = "25.11";

  # Nixarchy's home module reads programs.nixarchy.enable off the SYSTEM config
  # (osConfig), not off this one, so it is set in hosts/nixos/configuration.nix.
  # The live config also sets it here, inside home-manager.users.mark, which
  # does nothing: there is no such option in the home module. Not copied.
  # The vendored config.fish is sourced from here rather than installed as
  # ~/.config/fish/config.fish. See the note below for why.
  #
  # interactiveShellInit rather than shellInit: it lands inside the
  # config.fish that Home Manager generates, and only interactive shells read
  # it. The sourced file opens with its own `if status is-interactive` guard
  # anyway, so it is safe either way.
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      if test -f "$HOME/.config/fish/dotfiles.fish"
        source "$HOME/.config/fish/dotfiles.fish"
      end
    '';
  };

  # "adopt" rather than the "theme-only" default.
  #
  # The dotfiles below install a real ~/.config/nvim containing gruvbox. Either
  # value keeps it -- nixarchy seeds omarchy-nvim only into a directory that
  # does not exist, and it never overwrites a theme.lua somebody wrote. The
  # difference is that "adopt" checks for the collision, prints which files
  # disagree with the Omarchy theme, and says the theme will not drive Neovim.
  # The default keeps it silently, which is the same outcome you only find out
  # about later.
  programs.nixarchy.neovim = "adopt";

  # The LazyVim checkout, vendored at dotfiles/neovim/.config/nvim.
  #
  # This is an OUT-OF-STORE symlink, and it has to be. A plain home.file
  # source is copied into the store and linked read-only, which breaks Neovim:
  #
  #   E5113: ... lazy/manage/lock.lua:14:
  #         ~/.config/nvim/lazy-lock.json: Read-only file system
  #
  # lazy.nvim writes lazy-lock.json back into the config directory on every
  # plugin install or `:Lazy update`. With a read-only config directory that
  # error aborts setup partway through and the lockfile can never be updated.
  # It is not a warning; it stops the sync. Verified by running the real
  # config both ways: against a store copy, sync aborts; against a writable
  # directory, all 72 locked plugins install and the lockfile stays writable.
  #
  # The alternative was vim.env.LAZY_STDPATH = true, which relocates the
  # lockfile to stdpath("data") and avoids the error. Rejected: it silently
  # retires the vendored lazy-lock.json, so the 72 pinned versions would stop
  # being honoured and LazyVim would drift to whatever is newest. Keeping the
  # lockfile authoritative is worth an out-of-store link.
  #
  # Consequence, and it is the intended one: `:Lazy update` rewrites
  # dotfiles/neovim/.config/nvim/lazy-lock.json in the checkout, so the repo
  # shows a modified file that gets committed like any other dotfile change.
  #
  # The target is /etc/nixos, not the path this branch is being built from,
  # because that is where the flake lives once nixos-rebuild runs --
  # programs.nixarchy.flake is already set to it in hosts/nixos/default.nix.
  # Building and testing from a clone still works; only activation needs the
  # repo in place, which is the same requirement as every other out-of-store
  # dotfile.
  home.file.".config/nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink (repoDir + "/dotfiles/neovim/.config/nvim");
    recursive = true;
  };

  # Fish.
  #
  # The parts of the vendored fish config that CANNOT collide with Home
  # Manager are installed under their real names: conf.d, functions,
  # completions and fish_variables.
  #
  # config.fish is the exception, and the reason is a genuine activation-time
  # hazard rather than a tidiness concern.
  #
  # Enabling programs.fish makes Home Manager GENERATE
  # ~/.config/fish/config.fish, because that is where it injects
  # home.packages and home.sessionVariables into fish. On this account those
  # are not empty -- 14 packages and LOCALE_ARCHIVE -- so disabling
  # programs.fish to avoid the collision would silently drop them from the
  # shell.
  #
  # Installing the dotfiles as home.file.".config/fish" with recursive = true
  # makes ~/.config/fish a SYMLINK to a store path, and then Home Manager's
  # own target ~/.config/fish/config.fish nests INSIDE that symlink. The two
  # are not the same target name, so Home Manager's checkLinkTargets does not
  # catch it, and the system build succeeds. Activation would then try to
  # write config.fish into a read-only store directory.
  #
  # So config.fish is installed as the separate name dotfiles.fish and sourced
  # from programs.fish.interactiveShellInit above. One owner per path: Home
  # Manager owns config.fish, the dotfiles own dotfiles.fish, and your content
  # runs last -- after HM has set the PATH, which is the order you want.
  home.file.".config/fish/conf.d" = {
    source = dotfiles + "/fish/.config/fish/conf.d";
    recursive = true;
  };
  home.file.".config/fish/functions" = {
    source = dotfiles + "/fish/.config/fish/functions";
    recursive = true;
  };
  home.file.".config/fish/completions" = {
    source = dotfiles + "/fish/.config/fish/completions";
    recursive = true;
  };
  # ~/.config/fish/fish_variables is deliberately NOT managed.
  #
  # ~/.config/fish is a real directory here -- Home Manager links individual
  # files into it rather than symlinking the directory -- so fish can write it.
  # Managing it as a store symlink would make it read-only, and fish would then
  # silently fail to persist every new `set -U`, forever.
  #
  # Nothing is lost by leaving it alone. Its single meaningful entry is
  # SETUVAR fish_user_paths, and fish regenerates that on its own from the two
  # fish_add_path calls / PATH lines at the end of config.fish. It is
  # self-healing, so seeding it by hand buys nothing.
  home.file.".config/fish/dotfiles.fish" = {
    source = dotfiles + "/fish/.config/fish/config.fish";
  };

  # Terminal.
  #
  # The vendored Ghostty config is NOT used as-is. Two of its lines are wrong on
  # NixOS:
  #
  #   command = /usr/bin/fish
  #     /usr/bin/fish does not exist. The shell is at
  #     /run/current-system/sw/bin/fish. As written, Ghostty would try to exec a
  #     missing file on every launch.
  #
  #   theme = noctalia
  #     noctalia is a Quickshell shell from the old niri setup, not one of
  #     nixarchy's themes. You asked to keep the omarchy theme, so the theme
  #     line is dropped and Ghostty inherits the system one.
  #
  # Everything else from that file is kept verbatim.
  home.file.".config/ghostty/config" = {
    text = ''
      window-decoration = false
      gtk-titlebar = false
      background-opacity = 0.95
      background-blur = true
      font-family = JetBrainsMono Nerd Font Mono
      font-size = 12
      window-padding-x = 12
      window-padding-y = 12
      confirm-close-surface = false
      mouse-scroll-multiplier = precision:0.5,discrete:1
    '';
  };

  # ---------------------------------------------------------------------------
  # Vendored as-is. No conflicts found with nixarchy.
  home.file.".config/yazi" = {
    source = dotfiles + "/yazi/.config/yazi";
    recursive = true;
  };
  home.file.".config/lazygit" = {
    source = dotfiles + "/lazygit/.config/lazygit";
    recursive = true;
  };
  home.file.".config/bat" = {
    source = dotfiles + "/bat/.config/bat";
    recursive = true;
  };
  home.file.".config/btop" = {
    source = dotfiles + "/btop/.config/btop";
    recursive = true;
  };
  home.file.".config/fastfetch" = {
    source = dotfiles + "/fastfetch/.config/fastfetch";
    recursive = true;
  };
  home.file.".config/fzf" = {
    source = dotfiles + "/fzf/.config/fzf";
    recursive = true;
  };

  # ---------------------------------------------------------------------------
  # Vendored out-of-store, not from the store.
  #
  #   zathura/
  #     Vendored because it collides with omarchy's own theming rather than
  #     because it is inert. The file that matters is zathurarc, and the
  #     omarchy hook at ~/.config/omarchy/hooks/theme-set.d/zathura rewrites it
  #     in place, between the markers it writes, on every `omarchy theme set`.
  #
  #     Out-of-store for that reason. home.file with a plain `source` would put
  #     the directory in /nix/store and symlink from there; the hook's `install`
  #     would then write into the read-only store and fail, leaving zathura
  #     pinned to whatever colours were baked in at build time. Verified: an
  #     `install` onto a symlink to a read-only store path cannot land.
  #
  #     It also has to be a symlink to the DIRECTORY, not to zathurarc. The hook
  #     writes with `install`, which replaces a symlinked file rather than
  #     following it -- so a file-level symlink would be clobbered on the first
  #     theme change and the settings would stop being tracked. Going through
  #     the directory symlink writes the real file in the checkout instead.
  #
  #     The colours live in the same zathurarc as the settings above, between the
  #     hook's markers, so a theme change rewrites the block and leaves the
  #     settings untouched. That is why the file is edited in the checkout and
  #     not generated: both halves have to survive in one file.
  home.file.".config/zathura" = {
    source = config.lib.file.mkOutOfStoreSymlink (repoDir + "/dotfiles/zathura/.config/zathura");
    recursive = true;
  };

  # ---------------------------------------------------------------------------
  # niri and Noctalia, vendored out-of-store.
  #
  # Both are out-of-store, and Noctalia's reason is not optional: it writes
  # ~/.config/noctalia/config.json on first run and rewrites it on every
  # settings change. A plain `source` would put the directory in /nix/store and
  # symlink from there, so those writes would hit a read-only path and Noctalia
  # would fail to save anything -- the same failure zathura documents below, for
  # the same reason. Out-of-store means ~/.config/noctalia IS the checkout
  # directory, so what Noctalia writes lands in the repo where it can be seen
  # and committed.
  #
  # niri is out-of-store for consistency and editability rather than necessity
  # -- niri does not write to its config directory -- so the config can be
  # tweaked live without a rebuild.
  #
  # What is NOT vendored is Noctalia's generated config itself. Only the two
  # files that have to exist before Noctalia starts are: templates.toml (the
  # list of third-party apps Noctalia themes on startup, which is how the
  # gruvbox scheme reaches btop, ghostty, bat and the rest) and brightness.toml
  # (per-monitor brightness backends). Everything else Noctalia generates is
  # Noctalia's to write.
  #
  # The niri config needed one edit to be loadable at all; see the comment above
  # `/* gestures {` in dotfiles/niri/.config/niri/config.kdl. Its touchscreen
  # gesture block was niri-tablet syntax, and niri 26.04 from nixpkgs rejects all
  # three nodes and refuses to start on a config that does not parse. It is
  # commented out, verbatim, so pointing programs.niri.package at that fork and
  # uncommenting is the whole of restoring it.
  home.file.".config/niri" = {
    source = config.lib.file.mkOutOfStoreSymlink (repoDir + "/dotfiles/niri/.config/niri");
    recursive = true;
  };
  home.file.".config/noctalia" = {
    source = config.lib.file.mkOutOfStoreSymlink (repoDir + "/dotfiles/noctalia/.config/noctalia");
    recursive = true;
  };

  # ---------------------------------------------------------------------------
  # niri-rotate: manual display rotation, for the four keybinds that sit at the
  # bottom of dotfiles/niri/.config/niri/config.kdl.
  #
  #   Mod+Shift+A rotate left     Mod+Shift+Z reset to normal
  #   Mod+Shift+D rotate right    Mod+Shift+X toggle auto-rotation
  #
  # WHY A SCRIPT
  #
  #   Auto-rotation is iio-niri's, and it works. Overruling it by hand has no
  #   route through the obvious commands:
  #
  #     niri msg action   no rotate action, checked against the 26.04 list
  #     iio-niri msg      lock-rotation, toggle-lock-rotation, change-monitor,
  #                      change-transform, ping, stop, print-state
  #     Noctalia          no rotation control in the installed version
  #
  #   niri does expose it one level down, and this wraps that:
  #   `niri msg output <NAME> transform <T>` changes the output temporarily and
  #   does not touch config.kdl.
  #
  # THE PART THAT IS EASY TO GET WRONG
  #
  #   iio-niri reverts any transform set behind its back. A manual
  #   `niri msg output eDP-1 transform 90` with rotation unlocked is visible for
  #   well under a second and then snaps back to whatever the accelerometer says,
  #   which from the keyboard reads as the keybind doing nothing at all. So each
  #   command locks rotation *before* it writes the transform, and `unlock` is
  #   how control goes back. Measured: locked, set 90, still 90 four seconds on.
  #
  #   `change-transform` is deliberately not used. It rewrites the orientation to
  #   transform mapping, which is the fix for auto-rotation picking the wrong
  #   angle, and is not something a manual keybind should be adjusting.
  #
  # It lives here rather than in homeManagerModules/scripts/ because that tree is
  # inert (see the imports comment above): a package added there would build and
  # never be activated. niri spawns this by bare name, which resolves through
  # ~/.nix-profile/bin, the first entry in niri's own PATH.
  #
  # The script pins absolute tool paths rather than trusting PATH, so it behaves
  # the same from a keybind, a TTY and a systemd unit. niri spells its transform
  # field three different ways depending on how it got set -- "normal" from
  # config.kdl, "Normal" from `niri msg output`, "Flipped90" with no dash for the
  # mirrored angles -- so values are lowercased once on the way in.
  home.packages = [
    (pkgs.writeShellScriptBin "niri-rotate" ''
      set -euo pipefail

      OUTPUT="''${NIRI_ROTATE_OUTPUT:-eDP-1}"
      NIRI="${pkgs.niri}/bin/niri"
      IIO_NIRI="${pkgs.iio-niri}/bin/iio-niri"
      JQ="${pkgs.jq}/bin/jq"
      NOTIFY_SEND="${pkgs.libnotify}/bin/notify-send"

      # iio-niri only speaks over its IPC socket, so this doubles as the check
      # for whether it is running at all. Without it there is nothing to lock and
      # nothing to fight, and a bare transform is all that is needed.
      sensor_running() {
        "$IIO_NIRI" msg ping >/dev/null 2>&1
      }

      lock_state() {
        if sensor_running; then
          "$IIO_NIRI" msg print-state 2>/dev/null \
            | "$JQ" -r '.response.lock_rotation'
        else
          echo "no-sensor"
        fi
      }

      current_transform() {
        local raw
        raw="$("$NIRI" msg -j outputs \
          | "$JQ" -er --arg o "$OUTPUT" \
              'if .[$o] then .[$o].logical.transform
               else error("no such output: " + $o) end')" || exit 1
        printf '%s' "$raw" | tr '[:upper:]' '[:lower:]'
      }

      # Angle and mirror are tracked apart, so left and right step through the
      # angles without silently dropping a flipped prefix.
      current_flip() {
        case "$1" in
          flipped*) echo flipped ;;
          *)        echo plain ;;
        esac
      }

      current_deg() {
        local t="''${1#flipped}"
        t="''${t#-}"
        case "$t" in
          normal|"") echo 0 ;;
          90)         echo 90 ;;
          180)        echo 180 ;;
          270)        echo 270 ;;
          *)          echo "unrecognized transform: $1" >&2; exit 1 ;;
        esac
      }

      deg_label() {
        local t
        case "$1" in
          normal)
            echo "normal"
            ;;
          flipped*)
            t="''${1#flipped}"
            t="''${t#-}"
            if [ -z "$t" ]; then
              echo "flipped"
            else
              echo "$t° flipped"
            fi
            ;;
          *)
            echo "$1°"
            ;;
        esac
      }

      report() {
        local text lock

        text="Display: $(deg_label "$1")"
        lock="$(lock_state)"
        case "$lock" in
          true)      text="$text  (rotation locked, sensor idle)" ;;
          false)     text="$text  (auto-rotation active)" ;;
          no-sensor) text="$text  (iio-niri not running)" ;;
        esac

        echo "$text"
        if [ -x "$NOTIFY_SEND" ]; then
          "$NOTIFY_SEND" --expire-time=2000 niri-rotate "$text" >/dev/null 2>&1 || true
        fi
      }

      set_transform() {
        if sensor_running; then
          # Lock first. Writing the transform while iio-niri is still live just
          # races it and loses.
          "$IIO_NIRI" msg lock-rotation true >/dev/null
        fi
        "$NIRI" msg output "$OUTPUT" transform "$1"
        report "$1"
      }

      step() {
        # $1 is the number of degrees to add to the current transform.
        local transform flip deg next

        transform="$(current_transform)"
        flip="$(current_flip "$transform")"
        deg="$(current_deg "$transform")"
        next=$(( (deg + $1) % 360 ))

        if [ "$flip" = flipped ]; then
          set_transform "flipped-$next"
        elif [ "$next" -eq 0 ]; then
          set_transform normal
        else
          set_transform "$next"
        fi
      }

      case "''${1:-}" in
        left)
          step 90
          ;;
        right)
          step 270
          ;;
        normal)
          set_transform normal
          ;;
        cycle)
          case "$(current_deg "$(current_transform)")" in
            270) set_transform normal ;;
            *)   step 90 ;;
          esac
          ;;
        lock)
          if ! sensor_running; then
            echo "iio-niri is not running, nothing to lock"
            exit 0
          fi
          "$IIO_NIRI" msg lock-rotation true >/dev/null
          report "$(current_transform)"
          ;;
        unlock)
          if ! sensor_running; then
            echo "iio-niri is not running"
            exit 0
          fi
          "$IIO_NIRI" msg lock-rotation false >/dev/null
          # Reset to normal on the way out. Unlocking while the panel is sideways
          # would otherwise leave the last manual transform on screen until the
          # next orientation change, which reads as the unlock not having worked.
          "$NIRI" msg output "$OUTPUT" transform normal
          report "$(current_transform)"
          ;;
        toggle)
          if [ "$(lock_state)" = true ]; then
            "$0" unlock
          else
            "$0" lock
          fi
          ;;
        status)
          echo "output:    $OUTPUT"
          echo "transform: $(current_transform)"
          echo "locked:    $(lock_state)"
          ;;
        *)
          echo "usage: niri-rotate left|right|normal|cycle|lock|unlock|toggle|status" >&2
          exit 2
          ;;
      esac
    '')
  ];

  # ---------------------------------------------------------------------------
  # Noctalia's settings.toml, so the shell looks the same after a rebuild.
  #
  # Settings live in the state dir, not the config dir, so ~/.config/noctalia
  # being a symlink does nothing for them. Left alone, every setting Noctalia
  # writes -- bar layout, theme, enabled plugins, the lockscreen widgets, the
  # wallpaper -- would live in ~/.local/state and be lost to a fresh machine,
  # and invisible to git.
  #
  # This is the one Noctalia file that is NOT out-of-store, and it cannot be:
  # Noctalia rewrites it atomically on every settings change, through a temp
  # file and a rename. A symlink into /nix/store would break the rename (the
  # store is read-only, and the temp file would land somewhere else), which is
  # exactly the failure mode the out-of-store comments above describe. A store
  # symlink would also be reverted by every rebuild, discarding whatever changed
  # in between.
  #
  # So the file is linked, not copied, and the link is made the same way the
  # four above are. A store path as the source would be a copy that every
  # rebuild overwrites, which would silently discard whatever changed in
  # between.
  #
  # One caveat, since Noctalia writes this file through a temporary file and a
  # rename: if it does, the symlink is replaced by a regular file and the repo
  # copy stops tracking changes until the link is recreated. The link is
  # recreated on the next activation, which restores the committed baseline --
  # so the file is a baseline, not a live mirror. To move changes back into the
  # repo by hand:
  #   cp ~/.local/state/noctalia/settings.toml \
  #     /etc/nixos/dotfiles/noctalia/.local/state/noctalia/settings.toml
  #   rm ~/.local/state/noctalia/settings.toml && nixos-rebuild switch
  #
  # Edit brightness.toml for brightness; edit this for everything else.
  # ---------------------------------------------------------------------------
  home.file.".local/state/noctalia/settings.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink (repoDir + "/dotfiles/noctalia/.local/state/noctalia/settings.toml");
  };

  # ---------------------------------------------------------------------------
  # hyprchromad: stop the restart loop under niri.
  #
  # This is a Home Manager service because nixarchy-omatheme defines it under
  # home-manager.users.<user>, so it can only be overridden here. Setting
  # systemd.user.services.hyprchromad from a NixOS module would declare a
  # different option that nothing reads.
  #
  # Why it needs capping. The unit is WantedBy=graphical-session.target, so it
  # starts in every Wayland session, niri included. Its daemon ends by calling
  # `hyprchroma-state watch-events`, which looks up Hyprland's event socket:
  #
  #   signature = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
  #   if not signature or not runtime:
  #       return None
  #
  # Under niri that variable is never set -- there is no Hyprland to set it, and
  # it is not in the systemd --user manager environment either. So watch-events
  # returns immediately, every time, with status 0. The unit carries
  # Restart=always and RestartSec=2 because upstream expects Hyprland to still be
  # starting at login and to appear shortly; under niri it never will.
  #
  # Measured on this machine: 71 restarts in the first 19 minutes of the session,
  # each cycle consuming ~13.5s of CPU over ~16s of wall clock (systemd's own
  # "Consumed 13.495s CPU time over 16.255s wall clock time"), with
  # hyprchroma-state write-file sitting at 88.8% CPU. Tctl held at 68C; stopping
  # the unit dropped it to 47C in 25 seconds. That is the whole of the fan spinup
  # on niri -- nothing to do with Noctalia or niri itself.
  #
  # Why these numbers. Start rate limiting is the one fix that leaves the
  # Hyprland session alone. Under Hyprland the daemon succeeds and blocks on the
  # socket, so it never restarts and the limit is never reached. Under niri it
  # burns roughly 85s of CPU at login across five attempts, then the unit stays
  # `failed` and quiet for the rest of the session.
  #
  # StartLimitBurst=5 over a 300s window is deliberately generous. systemd's
  # default limit (5 starts in 10s) never trips here, because each loop cycle
  # takes ~17s -- longer than the window -- which is why this ran forever. The
  # window has to exceed one cycle for the counting to work at all, and it has to
  # leave Hyprland room to appear on a slow login, or a slow Hyprland boot would
  # trip the limit and lose the theme sync that session is actually getting today.
  #
  # The service failing is the intended outcome, not a leftover: there is nothing
  # for it to do without Hyprland. To get theme sync back on this machine under
  # Hyprland, drop the block below.
  systemd.user.services.hyprchromad.Unit = {
    StartLimitIntervalSec = 300;
    StartLimitBurst = 5;
  };

  # ---------------------------------------------------------------------------
  # Deliberately not vendored:
  #
  #   matugen/
  #     The theme generator. The dotfiles carry generated output from it
  #     (btop themes, calibre palette, arduino-ide theme, fastfetch theme) but
  #     the generator itself is not being wired up: nixarchy has its own theme
  #     path and re-running matugen at every activation would fight it. The
  #     generated files are shipped as they are.
  #
  #   bin/.local/bin
  #     Four scripts (aider, keybinds-float, sync-matugen-apps.py, ...). Two are
  #     wrappers around tools that are not being installed yet. Not wired up
  #     until it is clear which are still wanted.
  #
  #   freecad/, kicad/, qucs/, orcaslicer/, xournalpp/, hydralauncher/,
  #   arduino-ide/, calibre/, calibre-tui/, aider/
  #     Application configuration for programs that ARE installed as packages.
  #     These are per-application config directories whose layouts differ between
  #     versions; wiring them blind is more likely to break the applications
  #     than to help. They are the obvious next step once you confirm each one
  #     still launches.
  #
  #   ghostty/.config/ghostty/config
  #     Replaced by the inline config above, for the two broken lines.

  # ---------------------------------------------------------------------------
  # niri-solo-width: full width when a workspace holds one window.
  #
  # This is the behaviour the old Omarchy/Hyprland desktop had for free and niri
  # does not have at all:
  #
  #   new window on an empty workspace -> full width
  #   another window opens            -> both shrink to 50%
  #   all the others close             -> expand again
  #
  # Niri cannot express this in its config. Its scrolling layout resolves a
  # column width as (working_width - gaps) * proportion, with no special case
  # for a column that is alone on the workspace -- see resolve_column_width in
  # src/layout/scrolling.rs. So default-column-width { proportion 0.5; } holds a
  # lone window at half the screen forever.
  #
  #   window-rule { open-maximized true }
  #
  # looks like the answer and is not. Measured on this machine before writing
  # any of this: with one window alone it goes full width, and when a peer opens
  # beside it the maximized column stays full width (1675px) while the new
  # window takes 829px. They overlap instead of splitting. Maximized state also
  # has no tie to window count -- set_maximized in scrolling.rs only clears on
  # an explicit request or on leaving tabbed display, so it never demotes on its
  # own.
  #
  # Hyprland had no such rule because its scrolling layout did this itself.
  # ~/.config/hypr/hyprforge/state.json records scrolling:column_width 0.5, and
  # that layout widens a lone window to fill the workspace.
  #
  # So this runs the missing half as a daemon. It watches niri's IPC event
  # stream and applies the width itself, only on the transition, so a width set
  # by hand is never overwritten just because a window opened somewhere else.
  #
  # Why it is addressed by window id. The obvious call is SetColumnWidth, but it
  # takes no id and only ever affects the *focused* column -- so reaching the
  # others through it would mean repeatedly stealing focus. SetWindowWidth takes
  # an id, and layout.rs routes it to scrolling.set_window_width for a tiled
  # window, which finds the owning column by id. Focus is never moved. Verified
  # live: window 21 was resized to 1888px by id while window 22 kept focus.
  #
  # Started only in an niri session. It needs NIRI_SOCKET, which only niri sets,
  # and under Hyprland there is no such socket to connect to -- without this gate
  # the unit would restart-loop on every Hyprland login, the same failure mode
  # hyprchromad has above. ExecStartPre exits non-zero when NIRI_SOCKET is
  # unset, and Restart=on-failure means that ends as `failed`, quiet, for the
  # rest of the session.
  systemd.user.services.niri-solo-width = {
    # Gated on the desktop being niri, not merely on a Wayland session existing:
    # Hyprland sessions set WAYLAND_DISPLAY too, and there is no NIRI_SOCKET
    # there, so this test is the only thing standing between this unit and the
    # restart-loop hyprchromad documents above.
    Unit = {
      Description = "Expand a lone niri window to full width, and shrink it back when peers appear";
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
    };

    Service = {
      ExecStartPre = "${pkgs.runtimeShell} -c 'test -n \"$$NIRI_SOCKET\"'";
      ExecStart = "${pkgs.callPackage ../../modules/packages/niri-solo-width.nix { }}/bin/niri-solo-width";
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}