{ pkgs, inputs, ... }:
{
  imports = [
    inputs.niri.homeModules.niri
    inputs.noctalia.homeModules.default
        #    ./app-launcher.nix
        #    ./audio.nix
        #    ./bar.nix
        #    ./calendar.nix
        #    ./colors.nix
        #    ./control-center.nix
        #    ./desktop-widgets.nix
        #    ./dock.nix
        #    ./location.nix
        #    ./network.nix
        #    ./notifications.nix
        #    ./osd.nix
        #    ./power.nix
        #    ./session-menu.nix
        #    ./sounds.nix
        #    ./system-monitor.nix
        #    ./ui.nix
        #./wallpaper.nix
  ];

  programs.niri = {
    enable = true;
    package = pkgs.niri-unstable;
    settings = {
      spawn-at-startup = [
        {
          command = [ "noctalia-shell" ];
        }
      ];
      prefer-no-csd = true;
      input = {
        focus-follows-mouse = {
          enable = true;
          max-scroll-amount = "0%";
        };
      };
    };
  };
  programs.noctalia-shell = {
    enable = true;
    settings = {
      noctaliaPerformance = {
        disableWallpaper = true;
        disableDesktopWidgets = true;
      };
      general = {
        avatarImage = "";
        dimmerOpacity = 0.2;
        showScreenCorners = false;
        forceBlackScreenCorners = false;
        scaleRatio = 1.25;
        radiusRatio = 1;
        iRadiusRatio = 1;
        boxRadiusRatio = 1;
        screenRadiusRatio = 1;
        animationSpeed = 1;
        animationDisabled = false;
        compactLockScreen = false;
        lockScreenAnimations = false;
        lockOnSuspend = true;
        showSessionButtonsOnLockScreen = true;
        showHibernateOnLockScreen = false;
        enableLockScreenMediaControls = false;
        enableShadows = true;
        enableBlurBehind = true;
        shadowDirection = "bottom_right";
        shadowOffsetX = 2;
        shadowOffsetY = 3;
        language = "";
        allowPanelsOnScreenWithoutBar = true;
        showChangelogOnStartup = true;
        telemetryEnabled = false;
        enableLockScreenCountdown = true;
        lockScreenCountdownDuration = 10000;
        autoStartAuth = false;
        allowPasswordWithFprintd = false;
        clockStyle = "custom";
        clockFormat = "hh\nmm";
        passwordChars = false;
        lockScreenMonitors = [ ];
        lockScreenBlur = 0;
        lockScreenTint = 0;
        keybinds = {
          keyUp = [
            "Up"
          ];
          keyDown = [
            "Down"
          ];
          keyLeft = [
            "Left"
          ];
          keyRight = [
            "Right"
          ];
          keyEnter = [
            "Return"
            "Enter"
          ];
          keyEscape = [
            "Esc"
          ];
          keyRemove = [
            "Del"
          ];
        };
        reverseScroll = false;
      };
    };
  };

}
