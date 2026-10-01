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
  # Deliberately not vendored:
  #
  #   niri/, noctalia/
  #     Both are EMPTY directories in the dotfiles repo. They are scaffolding
  #     for the compositor this machine no longer runs.
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
}