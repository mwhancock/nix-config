{ ... }:
{
  imports = [
    ./core/shell.nix
    ./core/terminal.nix
    ./core/git-config.nix
    ./core/session-vars.nix
    ./scripts/zenBackup.nix
    ./apps/cli-tools.nix
    ./apps/desktop-apps.nix
  ];
}
