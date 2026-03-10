{ ... }:

{

  imports = [
    ./core/shell.nix
    ./core/terminal.nix
    ./core/gitConfig.nix
    ./scripts/zenBackup.nix
    ./apps/cli-tools.nix
    ./apps/desktop-apps.nix
  ];
}
