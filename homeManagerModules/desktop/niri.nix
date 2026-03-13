{ inputs, ... }:
{
  imports = [
    inputs.niri.homeModules.niri
  ];

  programs.niri = {
    enable = true;

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
