{ ... }:
{
  programs.zed-editor = {
    enable = true;
    extensions = [
      "nix"
      "toml"
      "rust"
      "java"
    ];
    userSettings = {
      "autosave" = "on_focus_change";
      theme = {
        mode = "dark";
        dark = "Gruvbox Dark Hard";
        light = "Gruvbox Light Hard";
      };
      hour_format = "hour24";
      vim_mode = false;
    };
  };
}
