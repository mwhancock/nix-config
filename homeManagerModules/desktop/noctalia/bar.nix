{ pkgs, inputs, ... }:
{
  programs.noctalia-shell.settings = {
    bar = {
      barType = "simple";
      position = "top";
      monitors = [ ];
      density = "default";
      showOutline = false;
      showCapsule = true;
      capsuleOpacity = 1;
      capsuleColorKey = "none";
      widgetSpacing = 6;
      contentPadding = 2;
      fontScale = 1;
      enableExclusionZoneInset = true;
      backgroundOpacity = 0.93;
      useSeparateOpacity = false;
      floating = true;
      marginVertical = 4;
      marginHorizontal = 4;
      frameThickness = 8;
      frameRadius = 12;
      outerCorners = true;
      hideOnOverview = true;
      displayMode = "always_visible";
      autoHideDelay = 500;
      autoShowDelay = 150;
      showOnWorkspaceSwitch = true;
      widgets = {
        left = [
          {
            id = "Launcher";
          }
          {
            id = "Workspace";
          }
          {
            id = "ActiveWindow";
          }
        ];
        center = [
          {
            id = "Clock";
          }
          {
            id = "MediaMini";
          }
        ];
        right = [
          {
            id = "Tray";
          }
          {
            id = "NotificationHistory";
          }
          {
            id = "Battery";
          }
          {
            id = "SystemMonitor";
          }

          {
            id = "ControlCenter";
          }
        ];
      };
      mouseWheelAction = "none";
      reverseScroll = false;
      mouseWheelWrap = true;
      middleClickAction = "none";
      middleClickFollowMouse = false;
      middleClickCommand = "";
      rightClickAction = "controlCenter";
      rightClickFollowMouse = true;
      rightClickCommand = "";
      screenOverrides = [ ];
    };
  };
}
