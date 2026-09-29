{ pkgs, ... }:
{
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  # Allow the main user to manage VMs without sudo
  users.users.mark.extraGroups = [ "libvirtd" ];
}
