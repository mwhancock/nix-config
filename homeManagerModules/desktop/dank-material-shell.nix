{ inputs, ... }:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd.enable = false;
    niri.includes.filesToInclude = [
      "alttab"
      "binds"
      "colors"
      "layout"
      "outputs"
      "wpblur"
    ];
  };
}
