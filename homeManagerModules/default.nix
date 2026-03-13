{ ... }:
{
  imports = [
    ./apps/cli-tools.nix
    ./apps/desktop-apps.nix
    ./core/dms-mods.nix
    ./core/git-config.nix
    ./core/shell.nix
    ./core/session-vars.nix
    ./core/terminal.nix
    ./scripts/zenBackup.nix
  ];
}
