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

  environment.sessionVariables = {
    XDG_DATA_DIRS = lib.mkAfter [
      "/var/lib/flatpak/exports/share"
      "$HOME/.local/share/flatpak/exports/share"
    ];
    XKB_CONFIG_ROOT = "${pkgs.xkeyboard-config}/etc/X11/xkb";
  };

  nix.settings = {
    download-buffer-size = 524288000;
    substituters = [
      "https://cache.nixos.org"
      "https://niri.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "niri.cachix.org-1:Wv0OmO7PsuocRKzdYcQW5oNaIZQDx2K7m/7zTikB3Q4="
    ];
  };

  system.stateVersion = "25.11";
}
