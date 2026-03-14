{ inputs, lib, ... }:
{
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];

  programs.dank-material-shell = {
    enable = true;
    systemd.enable = false;

    niri = {
      enableKeybinds = false;
      enableSpawn = true;
      includes = {
        enable = true;
        override = true;
        originalFileName = "hm";
        filesToInclude = [
          "colors"
          "layout"
          "alttab"
          "outputs"
          "wpblur"
          "windowrules"
          "binds"
        ];
      };
    };
  };
  xdg.configFile."niri/dms/outputs.kdl".text = ''
    output "eDP-1" {
        mode "1920x1200@60"
        scale 1
    }
  '';

  home.activation.createDmsDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p /home/mark/.config/niri/dms
  '';
}
