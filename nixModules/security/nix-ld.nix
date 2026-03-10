{ pkgs, ... }:
{
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      alsa-lib
      wayland
      wayland-utils
      libxkbcommon
      vulkan-loader
      mesa
      libGL
      libglvnd
      xkeyboard-config
    ];
  };
}
