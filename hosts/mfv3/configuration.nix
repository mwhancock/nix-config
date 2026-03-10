{
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    #inputs.dms.homeModules.dank-material-shell
    #inputs.niri.homeModules.niri
    ../../nixModules
  ];
  environment.shells = with pkgs; [ fish ];
  programs.fish.enable = true;
  time.timeZone = "America/St_Johns";
  i18n.defaultLocale = "en_CA.UTF-8";
  system.stateVersion = "25.11";
}
