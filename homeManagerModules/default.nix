{...}: {
  imports = [
    ./apps/cli-tools.nix
    ./apps/desktop-apps.nix
    ./apps/nvim
    ./apps/thunar.nix
    ./apps/zathura.nix
    ./core/gtk.nix
    ./core/git-config.nix
    ./core/shell.nix
    ./core/session-vars.nix
    ./core/terminal.nix
    ./core/xdg-overrides.nix
    ./desktop/dank-material-shell.nix
    ./desktop/niri.nix
    #./desktop/noctalia
    ./scripts/zenBackup.nix
  ];
}
