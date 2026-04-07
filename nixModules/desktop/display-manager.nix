{...}: {
  services = {
    desktopManager.gnome.enable = false;
    desktopManager.plasma6.enable = false;
    displayManager.gdm.enable = true;
  };
}
