{ pkgs, ... }:

{
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
      xdg-desktop-portal-wlr
    ];

    config = {
      common = {
        default = [
          "gnome"
          "gtk"
          "wlr"
        ];
        "org.freedesktop.impl.portal.FileChooser" = "gnome";
        "org.freedesktop.impl.portal.OpenURI" = "gnome";
      };
    };
  };

  environment.etc."xdg-desktop-portal/portals.conf".text = ''
    [preferred]
    default=gnome;gtk;wlr;
    org.freedesktop.impl.portal.FileChooser=gnome
    org.freedesktop.impl.portal.OpenURI=gnome
  '';
}
