{ ... }:
{
  imports = [
    ./core/base.nix
    ./core/boot.nix
    ./core/filesystems.nix
    ./core/networking.nix
    ./hardware/bluetooth.nix
    ./hardware/audio.nix
    ./hardware/power.nix
    ./services/printing.nix
    ./services/ssh.nix
    ./services/tailscale.nix
    ./services/flatpak.nix
    ./services/virtualbox.nix
    ./desktop/display-manager.nix
    ./desktop/plasma.nix
    ./desktop/niri.nix
    ./desktop/keymap.nix
    ./security/nix-ld.nix
    ./users/mark.nix
    ./packages/system-packages.nix
  ];
}
