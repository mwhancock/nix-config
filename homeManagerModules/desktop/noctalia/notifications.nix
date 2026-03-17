{ ... }:
{
  programs.noctalia-shell.settings = {
    notifications = {
      enabled = true;
      enableMarkdown = false;
      density = "default";
      monitors = [ ];
      location = "top_right";
      overlayLayer = true;
      backgroundOpacity = 1;
      respectExpireTimeout = false;
      lowUrgencyDuration = 3;
      normalUrgencyDuration = 8;
      criticalUrgencyDuration = 15;
      clearDismissed = true;
      saveToHistory = {
        low = true;
        normal = true;
        critical = true;
      };
    };
  };
}
