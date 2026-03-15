{ pkgs, ... }:
{
  xdg.configFile."fontconfig/conf.d/10-hm-fonts.conf".force = true;
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/gtk.css".force = true;
  xdg.desktopEntries.nemo = {
    name = "Nemo";
    exec = "${pkgs.nemo-with-extensions}/bin/nemo";
  };
  xdg.desktopEntries.nvim = {
  name = "Neovim";
  exec = "ghostty -e nvim %F";
  terminal = false;
  mimeType = [
    "text/plain"
    "text/x-c"
    "text/x-csrc"
    "text/x-chdr"
    "text/x-java"
    "text/x-python"
    "application/x-shellscript"
  ];
};
 xdg.mimeApps = {
  enable = true;
  defaultApplications = {
    "inode/directory" = [ "thunar.desktop" ];
    "text/plain" = [ "nvim.desktop" ];
    "text/x-c" = [ "nvim.desktop" ];
    "text/x-csrc" = [ "nvim.desktop" ];
    "text/x-chdr" = [ "nvim.desktop" ];
    "text/x-java" = [ "nvim.desktop" ];
    "text/x-python" = [ "nvim.desktop" ];
    "application/x-shellscript" = [ "nvim.desktop" ];
  };
 };
}
