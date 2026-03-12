{ pkgs, ... }:
{
  home.sessionVariables = {
    EDITOR = "zed-editor";
    VISUAL = "zed-editor";
    TERMINAL = "ghostty";
    ZEN_PROFILE_DIR = "~/.config/zen zen-backup";
    XKB_CONFIG_ROOT = "${pkgs.xkeyboard-config}/etc/X11/xkb";
  };
}
