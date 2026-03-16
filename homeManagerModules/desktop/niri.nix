{ inputs, pkgs, ... }:
{
  imports = [
    inputs.niri.homeModules.niri
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
    settings = {
      prefer-no-csd = true;
      input = {
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "0%";
        };
      };
    };
  };
}
