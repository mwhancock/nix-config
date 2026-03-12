{ ... }:
{
  imports = [
    ./apps/cli-tools.nix
    ./apps/desktop-apps.nix
    ./core/git-config.nix
    ./core/shell.nix
    ./core/session-vars.nix
    ./core/terminal.nix
    ./desktop/dms.nix
    ./scripts/zenBackup.nix
  ];
}
