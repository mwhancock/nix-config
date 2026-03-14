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
      layout = {
        focus-ring = {
          width = 0;
        };
        border = {
          width = 0;
        };
      };
    };
  };
}
