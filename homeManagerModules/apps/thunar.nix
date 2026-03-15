{ pkgs, ... }:
{
  home.packages = with pkgs; [
    thunar-archive-plugin
    thunar-volman
  ];
}
