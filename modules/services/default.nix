# Services, filtered by the migration review.
#
# Kept:   libvirt, tailscale, printing, ssh
# Dropped: VPN, Kafka, Waydroid, Ollama, Flatpak, Portal
{ config, lib, pkgs, ... }:

{
  # Kept. NOTE the group addition is additive to the base list in
  # hosts/nixos/configuration.nix; NixOS merges list options, so this does not
  # replace it.
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.users.mark.extraGroups = [ "libvirtd" ];

  # Kept.
  services.tailscale.enable = true;
  networking.networkmanager.unmanaged = [ "interface-name:tailscale0" ];

  # Kept. Also in the live system's own configuration.nix, so this is a
  # no-op relative to what is already running.
  services.printing.enable = true;
  services.openssh.enable = true;

  # ---------------------------------------------------------------------------
  # Dropped, with reasons -- these are the ones that would actually break
  # something if imported, so they are worth writing down:
  #
  #   services.flatpak
  #     The old file declared four flatpaks AND imported nix-flatpak.nixosModules
  #     from the flake. Nixarchy has its own flatpak handling. Three layers for
  #     one subsystem.
  #
  #   xdg.portal
  #     Set extraPortals to gtk/gnome/wlr and defaulted to "gnome", while
  #     nixarchy manages the portal for Hyprland. It also wrote XDG_DATA_DIRS
  #     pointing at a store path that does not exist:
  #       ...hq58p9cjbkrfzandg0fgrlj07jgi8wpv-xdg-desktop-portal-gtk-1.15.3/share
  #     That was the ONLY place hosts/mfv3's mkForce'd XDG_DATA_DIRS mattered;
  #     the rest of the forced list replaced Nixpkgs' defaults with five
  #     entries. Dropping the module drops the mkForce with it.
  #
  #   services.ollama
  #     Superseded by programs.nixarchy.localAi, which stays enabled.
  #
  #   services.apache-kafka
  #     clusterId was the literal placeholder "xxxxxxxxxxxxxxxxxxxxxx".
  #
  #   networking.wg-quick.interfaces.wg0
  #     Dropped as instructed, but see below -- this is not a cleanup.
  #
  #   virtualisation.waydroid
  #     Was already enable = false.

  # ---------------------------------------------------------------------------
  # The WireGuard key that was committed to this repository.
  #
  # This is not a note about tidiness. nixModules/services/vpn.nix contained a
  # plaintext `privateKey`, committed in 70634cc4 and pushed to origin/main,
  # which is a public repository. The key must be treated as compromised and
  # rotated at the server regardless of whether the interface is ever used
  # again. Removing the file does not un-publish the history.
  #
  # If a VPN is wanted later, the key belongs in agenix or sops-nix, never in
  # the tree.
}