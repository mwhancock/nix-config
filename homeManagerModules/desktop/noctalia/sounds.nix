{ ... }:
{
  programs.noctalia-shell.settings = {
    sounds = {
      enabled = false;
      volume = 0.5;
      separateSounds = false;
      criticalSoundFile = "";
      normalSoundFile = "";
      lowSoundFile = "";
      excludedApps = "discord,firefox,chrome,chromium,edge";
    };
    enableMediaToast = false;
    enableKeyboardLayoutToast = true;
    enableBatteryToast = true;
  };
}
