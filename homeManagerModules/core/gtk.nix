{ pkgs, lib, ... }:
{
  gtk = {
    enable = true;
    iconTheme = lib.mkForce {
      name = "Gruvbox-Plus-Dark";
      package = pkgs.adwaita-icon-theme;
    };
    theme = lib.mkForce {
      name = "Gruvbox-Dark-BL";
      package = pkgs.gnome-themes-extra;
    };
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
    };
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.adwaita-icon-theme;
    name = "Adwaita";
    size = 24;
  };
}
