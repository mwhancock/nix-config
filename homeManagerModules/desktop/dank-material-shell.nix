{ inputs, ... }:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
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
