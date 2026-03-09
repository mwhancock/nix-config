{
  programs.ghostty = {
    enable = true;
    settings = {
      #font setting
      font-size = 12;
      font-family = "JetBrainsMono Nerd Font";

      #appearance
      background-opacity = 0.7;
      background-blur = 15;
      window-theme = "dark";
      theme = "Gruvbox Dark Hard";
      window-decoration = false;
      window-padding-x = 10;
      window-padding-y = 10;

      #shell integration
      shell-integration = "fish";

      #cursor
      cursor-style = "bar";
      cursor-style-blink = true;

      #behavior
      copy-on-select = true;
    };
  };
}
