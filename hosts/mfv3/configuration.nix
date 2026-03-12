{
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../nixModules
  ];
  environment.shells = with pkgs; [ fish ];
  programs.fish.enable = true;
  time.timeZone = "America/St_Johns";
  i18n.defaultLocale = "en_CA.UTF-8";
  environment.systemPackages = with pkgs; [
    kdePackages.plasma-workspace
  ];
  programs.dank-material-shell.enable = true;

  environment.sessionVariables = {
    XDG_DATA_DIRS = lib.mkAfter [
      "/var/lib/flatpak/exports/share"
      "$HOME/.local/share/flatpak/exports/share"
    ];
    XKB_CONFIG_ROOT = "${pkgs.xkeyboard-config}/etc/X11/xkb";
  };

  system.stateVersion = "25.11";
}
