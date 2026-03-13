{ inputs, ... }:
{
  imports = [
    inputs.niri.homeModules.niri
  ];

  programs.niri = {
    enable = true;

    settings = {
      layout = {
        focus-ring = {
          enable = false;
        };
        border = {
          enable = false;
        };
      };
    };
  };
}
