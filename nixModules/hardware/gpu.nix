{ pkgs, ... }:
{
  hardware.amdgpu.opencl.enable = true;
  systemd.tmpfiles.rules = [
    "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"
  ];
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
}
