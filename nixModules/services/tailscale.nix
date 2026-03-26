{ ... }:
{
  services.tailscale.enable = true;
  networking.networkmanager.unmanaged = [ "interface-name:tailscale0" ];
}
