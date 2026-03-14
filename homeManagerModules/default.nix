{ ... }:
{
  imports = [
    ./apps/cli-tools.nix
    ./apps/desktop-apps.nix
    ./apps/zed.nix
    ./core/git-config.nix
    ./core/shell.nix
    ./core/session-vars.nix
    ./core/terminal.nix
    ./desktop/dank-material-shell.nix
    ./desktop/niri.nix
    ./scripts/zenBackup.nix
  ];
}
