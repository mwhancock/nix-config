{ ... }:
{
  programs.noctalia-shell.settings = {
    appLauncher = {
      enableClipboardHistory = true;
      autoPasteClipboard = false;
      enableClipPreview = true;
      clipboardWrapText = true;
      enableClipboardSmartIcons = true;
      enableClipboardChips = true;
      clipboardWatchTextCommand = "wl-paste --type text --watch cliphist store";
      clipboardWatchImageCommand = "wl-paste --type image --watch cliphist store";
      position = "center";
      pinnedApps = [ ];
      sortByMostUsed = true;
      terminalCommand = "ghostyy -e";
      customLaunchPrefixEnabled = false;
      customLaunchPrefix = "";
      viewMode = "list";
      showCategories = true;
      iconMode = "tabler";
      showIconBackground = false;
      enableSettingsSearch = true;
      enableWindowsSearch = true;
      enableSessionSearch = true;
      ignoreMouseInput = false;
      screenshotAnnotationTool = "";
      overviewLayer = false;
      density = "default";
    };
  };
}
