{ config, pkgs, ... }:

{
  home.username = "mark";
  home.homeDirectory = "/home/mark";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;
}
