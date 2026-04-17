{ pkgs, ... }:
{
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    TERMINAL = "ghostty";
    ZEN_PROFILE_DIR = "~/.config/zen zen-backup";
    XKB_CONFIG_ROOT = "${pkgs.xkeyboard-config}/etc/X11/xkb";
    GTK_THEME = "gruvbox-dark";
    ADW_DEBUG_COLOR_SCHEME = "prefer-dark";
    FILEMANAGER = "thunar";
    DEFAULT_FILEMANAGER = "thunar";
  };
}
