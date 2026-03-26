{...}: {
  imports = [
    ./core/base.nix
    ./core/boot.nix
    ./core/fonts.nix
    ./core/networking.nix
    ./desktop/display-manager.nix
    ./desktop/keymap.nix
    ./desktop/gnome.nix
    ./desktop/noctalia.nix
    ./desktop/thunar.nix
    ./hardware/audio.nix
    ./hardware/bluetooth.nix
    ./hardware/power.nix
    ./security/nix-ld.nix
    ./services/flatpak.nix
    ./services/ollama.nix
    ./services/portal.nix
    ./services/printing.nix
    ./services/ssh.nix
    ./services/tailscale.nix
    ./services/virtualbox.nix
    ./vpn.nix
    ./packages/system-packages.nix
    ./users/mark.nix
  ];
}
