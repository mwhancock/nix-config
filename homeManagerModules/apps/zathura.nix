{...}: {
  programs.zathura = {
    enable = true;
    options = {
      # Selection & UI colors
      selection-clipboard = "clipboard";
      notification-error-bg = "#fb4934"; # Red
      notification-error-fg = "#ebdbb2";
      notification-warning-bg = "#fabd2f"; # Yellow
      notification-warning-fg = "#282828";

      # Completion / Status bar
      completion-bg = "#3c3836";
      completion-fg = "#ebdbb2";
      completion-highlight-bg = "#83a598"; # Blue
      completion-highlight-fg = "#282828";

      recolor = "true";
      recolor-keephue = "true"; # Keeps images/colors from looking like a negative

      # Background of the page
      recolor-lightcolor = "#282828";
      # Foreground (text) color
      recolor-darkcolor = "#ebdbb2";

      # UI Background (The area around the page)
      default-bg = "#282828";
      default-fg = "#ebdbb2";

      statusbar-bg = "#3c3836";
      statusbar-fg = "#ebdbb2";

      # Highlighting
      highlight-color = "#fabd2f80";
      highlight-active-color = "#fe80198";
      highlight-fg = "#83a59880";

      # Smooth Scrolling
      scroll-step = "50";
      zoom-step = "10";

      # Selection Color
      selection-color = "#fe801980";
    };
  };
}
