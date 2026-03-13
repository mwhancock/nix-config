{ ... }:
{
  imports = [
    ./core/base.nix
    ./core/boot.nix
    ./core/networking.nix
    ./desktop/display-manager.nix
    ./desktop/dms-config.nix
    ./desktop/keymap.nix
    ./desktop/niri.nix
    ./desktop/plasma.nix
    ./hardware/audio.nix
    ./hardware/bluetooth.nix
    ./hardware/power.nix
    ./security/nix-ld.nix
    ./services/flatpak.nix
    ./services/printing.nix
    ./services/ssh.nix
    ./services/tailscale.nix
    ./services/virtualbox.nix
    ./packages/system-packages.nix
    ./users/mark.nix
  ];
}
