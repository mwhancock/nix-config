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
{ config, lib, pkgs, inputs, ... }:

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

  # The on-screen keyboard supervisor, addressed by store path so the user
  # service below does not depend on PATH. See
  # modules/packages/sysboard-ctl.nix for what it does and how it detects a
  # keyboard.
  sysboardCtl = pkgs.callPackage ../../modules/packages/sysboard-ctl.nix {
    sysboard = pkgs.callPackage ../../modules/packages/sysboard.nix { };
  };
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
  imports = [
    ../../homeManagerModules/core/fonts.nix
    inputs.open-bamboo-networking.hmModules.open-bamboo-networking
  ];

  # ---------------------------------------------------- Bambu network plugin
  #
  # OrcaSlicer's Bambu networking plugin is a proprietary blob it downloads at
  # runtime. That blob aborts the app on startup on this machine (SIGABRT /
  # "free(): invalid size" inside std::locale::~_Impl -- a C++ ABI mismatch
  # against the Nix-built OrcaSlicer; upstream bambulab/BambuStudio#3652).
  #
  # open-bamboo-networking is an open-source drop-in replacement with the same
  # dlsym ABI and filename. The flake module above builds it and links it into
  # the slicer's plugins/ dir. OrcaSlicer.conf also has to name the plugin
  # version it expects; that file is mutable app state, so it is patched by the
  # activation script below rather than managed as a store symlink.
  #
  # OrcaSlicer is now the Flathub build, whose ~/.config is redirected to its
  # per-app data dir, so configDir points there rather than at ~/.config/
  # OrcaSlicer (which belonged to the Nix build). The module deploys the plugin
  # as a store symlink, so the sandbox has to be able to read /nix/store -- see
  # the override in nixarchy/services.nix.
  programs.openBambooNetworking = {
    enable = true;
    orcaSlicer = {
      enable = true;
      obnVersion = "02.03.00.62";
      configDir = "${config.home.homeDirectory}/.var/app/com.orcaslicer.OrcaSlicer/config/OrcaSlicer";
    };
  };

  # Point OrcaSlicer at the open plugin. Runs every activation but only rewrites
  # the conf when it actually disagrees, backing the old one up to .bak. The
  # version is read from the same option the module built the .so from, so the
  # two cannot drift.
  home.activation.openBambuNetworkingOrcaConf = let
    cfg = config.programs.openBambooNetworking.orcaSlicer;
  in
    lib.hm.dag.entryAfter ["writeBoundary"] ''
      CONF=${lib.escapeShellArg "${cfg.configDir}/OrcaSlicer.conf"}
      if [ ! -e "$CONF" ]; then
        echo "open-bamboo-networking: $CONF does not exist yet; launch OrcaSlicer once, then re-run the rebuild"
      else
        NEEDS_PATCH=$(${pkgs.jq}/bin/jq -r --arg ver ${lib.escapeShellArg cfg.obnVersion} \
          '(.app.installed_networking != "true") or (.app.network_plugin_version != $ver)' "$CONF")
        if [ "$NEEDS_PATCH" = "true" ]; then
          $DRY_RUN_CMD cp -f "$CONF" "$CONF.bak"
          TMP=$(mktemp)
          ${pkgs.jq}/bin/jq --arg ver ${lib.escapeShellArg cfg.obnVersion} \
            '.app.installed_networking = "true"
             | .app.network_plugin_version = $ver
             | .app.network_plugin_remind_later = "true"' "$CONF" > "$TMP"
          cat "$TMP" > "$CONF"
          rm -f "$TMP"
          echo "open-bamboo-networking: patched $CONF (backup: $CONF.bak)"
        fi
      fi
    '';

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

  # Binaries installed by `cargo install` land in ~/.cargo/bin. Prepend it so
  # esp-generate and friends are callable by name.
  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

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

  # On-screen keyboard, for the tablet on its own.
  #
  # Height is in *logical* pixels, and the panel is 1066 of them (2560x1600 at
  # scale 1.5). The layout grid is row-homogeneous, so this height is divided
  # evenly across the full layout's five rows: 530 gives ~106px per row, which
  # after the 7px label margins is a ~90px key. That is about 19mm on this
  # 190mm-tall panel -- the pitch of a physical keyboard, which is what makes
  # the board typeable rather than a strip of soup at the bottom. The previous
  # 320 was ~64px/row and read as far too short.
  #
  # It is an exclusive zone, not an overlay: the focused window is pushed up
  # rather than covered, so this is a straight trade of screen for key size.
  # Margin stays at the upstream 10. layout=full is the standard QWERTY board;
  # the other shipped option is the narrower mobile one, in the same directory
  # in the nixpkgs-less install, so this is the single knob to change if the
  # board feels too wide.
  #
  # A plain home.file, not out-of-store: sysboard only ever reads this file, it
  # does not rewrite it the way noctalia rewrites its own config, so a
  # read-only store symlink is correct here. The colours are a separate file --
  # style.css -- generated by the theme-set.d hook below.
  home.file.".config/sys64/board/config.conf".text = ''
    [main]
    margin=10
    height=530
    layout=full
  '';

  # sysboard's colours, piped in from the wallpaper theme.
  #
  # sysboard reads style.css from ~/.config/sys64/board/ in preference to the
  # copy in its store path, and the store copy is written against GTK's named
  # colours -- @theme_base_color, @borders -- which follow the *GTK* theme, not
  # the Omarchy theme derived from the wallpaper. On top of that neither
  # /usr/share/sys64/board/style.css nor /usr/local/share/... exists here:
  # modules/packages/sysboard.nix rewrites only the config path in main.cpp,
  # not the style path in window.cpp. So without this file sysboard runs with
  # no stylesheet at all, which is why it looked unthemed.
  #
  # This is the same shape as the zathura hook below: Omarchy runs every script
  # in theme-set.d/ after `omarchy theme set`, passing the slug as $1, and each
  # theme ships a colors.toml. So a hook generates the stylesheet from the
  # active palette rather than a store file hardcoding one theme's colours --
  # a symlink would be wrong the moment the theme changed.
  #
  # style.css is deliberately NOT a home.file. The hook writes it, and it must
  # stay writable; a store symlink would make the write fail and pin sysboard
  # to whatever colours were baked in at build time. Only config.conf above is
  # managed, and sysboard never rewrites that one.
  home.file.".config/omarchy/hooks/theme-set.d/sysboard".text = ''
    #!/usr/bin/env bash
    # Tie sysboard to Omarchy's theme engine.
    #
    # Reads the active theme's colors.toml and writes the stylesheet sysboard
    # loads at startup. sysboard reads style.css once, at construction, so the
    # new colours only land on a restart -- and sysboard-ctl cannot notice an
    # externally killed child, because kill -0 still succeeds on the zombie.
    # So the unit itself is restarted instead of the process being killed.

    set -euo pipefail

    if (( $# < 1 )); then
      exit 0
    fi
    THEME_NAME=$1

    # User overlay first, then the stock theme, matching how Omarchy resolves a
    # theme: an overlay in ~/.config/omarchy/themes/<slug>/ wins over the stock
    # one, so a customised palette is picked up here too.
    COLORS_TOML="$HOME/.config/omarchy/themes/$THEME_NAME/colors.toml"
    [[ -f $COLORS_TOML ]] || COLORS_TOML="$OMARCHY_PATH/themes/$THEME_NAME/colors.toml"
    [[ -f $COLORS_TOML ]] || exit 0

    color() {
      # Read one key from colors.toml. The file is a flat `key = "#rrggbb"`
      # list, so a single anchored match is enough and needs no TOML parser.
      local key=$1 value
      value=$(sed -n "s/^$key[[:space:]]*=[[:space:]]*[\"']\{0,1\}\(#[[:xdigit:]]\{6\}\).*/\1/p" \
        "$COLORS_TOML" | head -1)
      printf '%s' "$value"
    }

    background=$(color background)
    dark_background=$(color dark_background)
    lighter_background=$(color lighter_background)
    foreground=$(color foreground)
    muted=$(color muted)
    selection=$(color selection)

    # Skip writing a partial palette. A theme with an unusual colors.toml
    # should leave the last good stylesheet in place rather than half-recolour
    # the board.
    for v in "$background" "$dark_background" "$lighter_background" "$foreground" "$muted" "$selection"; do
      [[ -n $v ]] || exit 0
    done

    # Keys are ~92px tall at height=530 (530 / 5 rows, less the 7px label
    # margins), so the upstream 18px legend -- sized for the old 64px rows --
    # would read as tiny. These follow the same ~0.28 legend-to-key and ~0.5
    # icon-to-key ratios upstream used, against the taller row.
    #
    # The four key glyphs are written out as SVGs rather than looked up in the
    # icon theme. Upstream asks for keyboard-shift-symbolic,
    # keyboard-spacebar and keyboard-enter, and those names exist in no theme
    # installed here -- only backspace's edit-clear-symbolic resolves, in
    # Adwaita -- so GTK showed its broken-image placeholder for the other three.
    # The icon theme is also set to Papirus-Dark, which is not installed at all.
    # Drawing them here means no dependency on the icon theme, and filling with
    # $foreground makes them follow the palette like everything else.
    ICONS="$HOME/.config/sys64/board/icons"
    mkdir -p "$ICONS"

    # Shift: filled up-arrow with a stem. The classic modifier glyph, solid so
    # it stays legible when the key is toggled and the background darkens.
    cat > "$ICONS/shift.svg" <<SVG
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
    	<path fill="$foreground" d="M24 8 L40 24 H31 V38 H17 V24 H8 Z"/>
    </svg>
    SVG

    # Backspace: the outlined pentagon with an X, matching the standard glyph.
    cat > "$ICONS/backspace.svg" <<SVG
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
    	<path fill="none" stroke="$foreground" stroke-width="3" stroke-linejoin="round"
    		d="M18 12 H42 A2 2 0 0 1 44 14 V34 A2 2 0 0 1 42 36 H18 L6 24 Z"/>
    	<path fill="none" stroke="$foreground" stroke-width="3" stroke-linecap="round"
    		d="M25 19 L37 31 M37 19 L25 31"/>
    </svg>
    SVG

    # Space: a solid rounded bar, the shape of the physical key.
    cat > "$ICONS/space.svg" <<SVG
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
    	<rect x="8" y="21" width="32" height="6" rx="3" fill="$foreground"/>
    </svg>
    SVG

    # Enter: the return arrow -- down, then left, with a chevron head.
    cat > "$ICONS/enter.svg" <<SVG
    <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48" width="48" height="48">
    	<path fill="none" stroke="$foreground" stroke-width="3.5"
    		stroke-linecap="round" stroke-linejoin="round"
    		d="M38 14 V26 A6 6 0 0 1 32 32 H11"/>
    	<path fill="none" stroke="$foreground" stroke-width="3.5"
    		stroke-linecap="round" stroke-linejoin="round"
    		d="M18 25 L11 32 L18 39"/>
    </svg>
    SVG

    STYLE="$HOME/.config/sys64/board/style.css"
    mkdir -p "$(dirname "$STYLE")"

    cat > "$STYLE" <<CSS
    /* Generated from the $THEME_NAME theme. Do not edit; change the Omarchy theme instead. */
    #sysboard {
    	background: $background;
    	border-top: 1px solid $muted;
    }

    #sysboard label {
    	background: $lighter_background;
    	color: $foreground;
    	border-top: 1px solid rgba(255, 255, 255, 0.05);
    	border-radius: 8px;
    	margin: 7px 3px;
    	box-shadow: 0px 2px 2px rgba(0, 0, 0, 0.15);
    	font-size: 26px;
    	font-weight: 500;
    	transition: background-color 0.1s ease-out;
    }

    /* Modifier and navigation keys sit darker than the alpha keys. */
    #sysboard .full .key-Esc label,
    #sysboard .full .key-Tab label,
    #sysboard .full .key-Caps label,
    #sysboard .key-Shift label,
    #sysboard .full .key-Ctrl label,
    #sysboard .full .key-Alt label,
    #sysboard .full .key-Meta label,
    #sysboard .full .key-Space label,
    #sysboard .full .key-← label,
    #sysboard .full .key-↑ label,
    #sysboard .full .key-↓ label,
    #sysboard .full .key-→ label,
    #sysboard .key-Enter label,
    #sysboard .full .key-\\\\ label,
    #sysboard .key-Backspace label,
    #sysboard .key-123 label,
    #sysboard .key-abc label {
    	background: $dark_background;
    }

    /* Icon keys: the glyph is the background image, so no text.
     *
     * These are files the hook writes, not -gtk-icontheme() lookups. Upstream
     * asks the icon theme for keyboard-shift-symbolic, keyboard-spacebar and
     * keyboard-enter; none of those three names exist in any theme installed
     * here (only backspace's edit-clear-symbolic does, in Adwaita), so GTK
     * fell back to its broken-image placeholder -- the little grey triangle and
     * exclamation. The theme also claims to be Papirus-Dark, which is not
     * installed at all. Drawing the glyphs here sidesteps the icon theme
     * entirely and colours them from $foreground, so they track the palette. */
    #sysboard .key-Shift label,
    #sysboard .key-Backspace label,
    #sysboard .key-Space label,
    #sysboard .key-Enter label {
    	font-size: 0px;
    	background-position: center;
    	background-size: 46px;
    	background-repeat: no-repeat;
    }

    #sysboard .key-Shift label {
    	background-image: url("file://$ICONS/shift.svg");
    }

    #sysboard .key-Backspace label {
    	background-image: url("file://$ICONS/backspace.svg");
    }

    #sysboard .key-Space label {
    	background-image: url("file://$ICONS/space.svg");
    }

    #sysboard .key-Enter label {
    	background-image: url("file://$ICONS/enter.svg");
    }

    #sysboard .key.toggled label,
    #sysboard .key.pressed label {
    	background-color: $selection;
    }
    CSS

    # sysboard only reads style.css at startup, so restart the supervisor to
    # apply it. Guard on is-active: with no physical keyboard attached the unit
    # is what starts sysboard at all, and restarting a stopped unit would
    # start a board that should stay hidden.
    if systemctl --user is-active --quiet sysboard-ctl; then
      systemctl --user restart sysboard-ctl || true
    fi
  '';

  # mermaid-mmdc.json, the palette Neovim's mermaid rendering renders with.
  #
  # Same shape as the sysboard hook above: Omarchy runs every script in
  # theme-set.d/ after `omarchy theme set` (invoked as `bash "$hook"`, so the
  # store symlink needs no exec bit) with the theme slug as $1, and each theme
  # ships a colors.toml. diagram.nvim passes this JSON to mmdc via -c, so
  # mermaid diagram colours follow every `omarchy theme set` the same way
  # ghostty, hyprland and sysboard do. Wallpaper cycling within a theme does
  # not fire the hook -- and does not recolour anything else either.
  #
  # The output JSON is deliberately NOT a home.file: the hook writes it and it
  # must stay writable; a store symlink would make the write fail and pin
  # diagrams to whatever palette was baked in at build time.
  home.file.".config/omarchy/hooks/theme-set.d/mermaid-mmdc".text = ''
    #!/usr/bin/env bash
    # Tie Neovim's mermaid rendering (diagram.nvim) to Omarchy's theme engine.
    #
    # Omarchy runs every script in ~/.config/omarchy/hooks/theme-set.d/ after a
    # theme change, passing the theme slug as $1. By the time hooks run,
    # omarchy-theme-set has already swapped the merged palette (stock theme plus
    # any user overlay) into ~/.local/state/omarchy/current/theme/, so that
    # colors.toml is the live truth -- the same file the shell itself consumes.
    #
    # This reads it and regenerates ~/.config/omarchy/mermaid-mmdc.json, the
    # mermaid-cli (mmdc) config that lua/plugins/diagram.lua passes via -c.
    # Diagram colours therefore follow every `omarchy theme set`, the same way
    # ghostty, hyprland and zathura do. Cycling the wallpaper within a theme
    # does not fire this hook -- and does not recolour anything else either;
    # the palette belongs to the theme, not the image.
    #
    # The JSON is a mermaid "base" theme: themeVariables are the knobs mermaid.js
    # exposes for custom palettes. Written atomically; an unusable palette leaves
    # the previous good file in place rather than half-recolouring diagrams.

    set -euo pipefail

    COLORS_TOML="$HOME/.local/state/omarchy/current/theme/colors.toml"
    [[ -f $COLORS_TOML ]] || exit 0

    OUT="$HOME/.config/omarchy/mermaid-mmdc.json"

    color() {
      # Read one key from colors.toml. The file is a flat `key = "#rrggbb"` list,
      # so a single anchored match is enough and needs no TOML parser.
      local key=$1 default=''${2:-} value
      value=$(sed -n "s/^''${key}[[:space:]]*=[[:space:]]*[\"']\{0,1\}\(#[[:xdigit:]]\{6\}\|#[A-Za-z0-9]\{12\}\|#[A-Za-z0-9]\{16\}\).*/\1/p" \
        "$COLORS_TOML" | head -1)
      printf '%s' "''${value:-$default}"
    }

    # Skip writing a partial palette. A theme with an unusual colors.toml should
    # leave the last good mermaid-mmdc.json in place rather than half-recolour it.
    mode=$(sed -n 's/^mode[[:space:]]*=[[:space:]]*"\(.*\)".*/\1/p' "$COLORS_TOML" | head -1)
    background=$(color background)
    foreground=$(color foreground)
    accent=$(color accent)
    red=$(color red)
    green=$(color green)
    yellow=$(color yellow)

    for v in background foreground accent red yellow green; do
      [[ -n ''${!v} ]] || exit 0
    done

    dark_background=$(color dark_background "$background")
    darker_background=$(color darker_background "$background")
    lighter_background=$(color lighter_background "$background")
    selection=$(color selection "$lighter_background")
    dark_foreground=$(color dark_foreground "$foreground")
    bright_foreground=$(color bright_foreground "$foreground")
    muted=$(color muted "$dark_foreground")
    blue=$(color blue "$accent")
    magenta=$(color magenta "$red")
    cyan=$(color cyan "$green")
    orange=$(color orange "$yellow")

    # Mermaid's darkMode flag switches a few built-in defaults (pie charts, class
    # diagrams) that themeVariables alone do not reach.
    if [[ $mode == light ]]; then
      dark_mode=false
    else
      dark_mode=true
    fi

    mkdir -p "$(dirname "$OUT")"

    tmp=$(mktemp)
    if jq -n \
      --arg bg "$background" \
      --arg dark_bg "$dark_background" \
      --arg darker_bg "$darker_background" \
      --arg lighter_bg "$lighter_background" \
      --arg sel "$selection" \
      --arg fg "$foreground" \
      --arg dark_fg "$dark_foreground" \
      --arg bright_fg "$bright_foreground" \
      --arg muted "$muted" \
      --arg accent "$accent" \
      --arg red "$red" \
      --arg green "$green" \
      --arg yellow "$yellow" \
      --arg blue "$blue" \
      --arg magenta "$magenta" \
      --arg cyan "$cyan" \
      --arg orange "$orange" \
      --argjson dark_mode "$dark_mode" \
      '{
        theme: "base",
        themeVariables: {
          darkMode: $dark_mode,
          background: $bg,
          mainBkg: $lighter_bg,
          nodeBorder: $accent,
          clusterBkg: $darker_bg,
          clusterBorder: $dark_fg,
          titleColor: $bright_fg,
          edgeLabelBackground: $bg,
          textColor: $fg,
          lineColor: $muted,
          primaryColor: $lighter_bg,
          primaryTextColor: $fg,
          primaryBorderColor: $accent,
          secondaryColor: $sel,
          secondaryTextColor: $fg,
          secondaryBorderColor: $green,
          tertiaryColor: $dark_bg,
          tertiaryTextColor: $fg,
          tertiaryBorderColor: $magenta,
          noteBkgColor: $yellow,
          noteTextColor: $bg,
          noteBorderColor: $yellow,
          errorBkgColor: $red,
          errorTextColor: $bg,
          git0: $green,
          git1: $blue,
          git2: $magenta,
          git3: $orange,
          git4: $cyan,
          git5: $yellow
        }
      }' >"$tmp"; then
      install -m 644 "$tmp" "$OUT"
    fi
    rm -f "$tmp"
  '';

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
    # The exporter behind Neovim's <leader>op / <leader>od keymaps. It was
    # referenced by the keymaps but never wired up, so the export always failed
    # with ENOENT: 'md-export'. See modules/packages/md-export.nix.
    (pkgs.callPackage ../../modules/packages/md-export.nix { })

    # mermaidfmt, behind Neovim's <leader>om keymap, which formats the
    # ```mermaid fences in the current buffer on demand. Not in nixpkgs; see
    # modules/packages/mermaid-formatter.nix for why it is fetched from npm and
    # why it is deliberately not wired into format-on-save.
    (pkgs.callPackage ../../modules/packages/mermaid-formatter.nix { })

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

  # ---------------------------------------------------------------------------
  # sysboard-ctl: the on-screen keyboard, but only with no keyboard attached.
  #
  # sysboard shows itself when the compositor activates a text field and hides
  # when focus leaves it -- that half is niri's and sysboard's own, over
  # zwp_input_method_v2, and it works here. What no sysboard option covers is
  # "do not do any of that when the user is already typing on a real keyboard".
  #
  # So sysboard is not started at all while a keyboard is present, and this unit
  # is the thing that runs to make that decision. The supervisor, its detection
  # rule and the reason it is a process gate rather than a signal are in
  # modules/packages/sysboard-ctl.nix.
  #
  # Gated on a Wayland session rather than on niri specifically. sysboard talks
  # zwp_input_method_v2, which is a compositor-agnostic protocol and one niri
  # advertises; there is no NIRI_SOCKET to test for here the way niri-solo-width
  # tests, and none is needed. ConditionEnvironment with no value tests that the
  # variable is set at all, which is only true once a compositor is up -- so the
  # unit waits for the session rather than racing it, and under a bare TTY it
  # simply does not start.
  systemd.user.services.sysboard-ctl = {
    Unit = {
      Description = "Run the sysboard on-screen keyboard only while no real keyboard is attached";
      PartOf = [ "graphical-session.target" ];
      ConditionEnvironment = "WAYLAND_DISPLAY";
    };

    Service = {
      ExecStart = "${sysboardCtl}/bin/sysboard-ctl";
      Type = "simple";
      Restart = "on-failure";
      RestartSec = 2;
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}