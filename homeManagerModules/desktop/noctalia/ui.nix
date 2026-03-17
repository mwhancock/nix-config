{ pkgs, ... }:
{
  programs.noctalia-shell.settings = {
    ui = {
      fontDefault = "JetBrains Mono";
      fontFixed = "";
      fontDefaultScale = 1;
      fontFixedScale = 1;
      tooltipsEnabled = true;
      scrollbarAlwaysVisible = true;
      boxBorderEnabled = false;
      panelBackgroundOpacity = 0.93;
      translucentWidgets = false;
      panelsAttachedToBar = true;
      settingsPanelMode = "attached";
      settingsPanelSideBarCardStyle = false;
    };
  };
}
