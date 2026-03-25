# -----------------------------------------------------------------------------
# MODULE: DANK MATERIAL SHELL (DMS)
# Description: Configuration for the DMS Flake and Niri integration.
# -----------------------------------------------------------------------------
{inputs, ...}: {
  imports = [
    inputs.dms.homeModules.dank-material-shell
    inputs.dms.homeModules.niri
  ];

  programs.dank-material-shell = {
    enable = true;

    # 1. SYSTEMD
    systemd.enable = false;

    # 2. NIRI CONFIGURATION WRAPPER
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
