{
  programs.ghostty = {
    enable = true;
    settings = {
      #font setting
      font-size = 12;
      font-family = "JetBrains Mono";

      #appearance
      background-opacity = 1;
      background-blur = 15;
      window-theme = "dark";
      theme = "Gruvbox Dark Hard";
      window-decoration = false;
      window-padding-x = 10;
      window-padding-y = 10;

      #shell integration
      shell-integration = "fish";

      cursor-color = "#fe8019";
      cursor-text = "#1d2021";

      #behavior
      copy-on-select = true;
      confirm-close-surface = false;

      font-feature = "+calt +liga +dlig";
    };
  };
}
