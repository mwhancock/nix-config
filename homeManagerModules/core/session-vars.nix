{ pkgs, ... }:
{
  home.sessionVariables = {
    EDITOR = "zed";
    VISUAL = "zed";
    TERMINAL = "ghostty";
    ZEN_PROFILE_DIR = "~/.config/zen zen-backup";
    XDG_DATA_DIRS = "/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    XKB_CONFIG_ROOT = "${pkgs.xkeyboard-config}/etc/X11/xkb";
  };
}
