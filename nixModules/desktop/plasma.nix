{ pkgs, ... }:
{
  services.desktopManager.plasma6.enable = true;
  environment.etc."xdg/menus/applications.menu".source =
    "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";
}
