{ inputs, ... }:
{
  xdg.configFile."niri/config.kdl".source = ./config.kdl;

  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.niri.homeModules.niri
  ];
  programs.dank-material-shell = {
    enable = true;

    niri.includes = {
      enable = true;

      override = true;
      originalFileName = "hm";
      filesToInclude = [
        "alttab"
        "binds"
        "colors"
        "layout"
        "outputs"
        "wpblur"
      ];
    };
  };
}
