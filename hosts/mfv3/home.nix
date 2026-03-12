{ inputs, ... }:
{
  imports = [
    ../../homeManagerModules/default.nix
    inputs.dms.homeModules.dank-material-shell
  ];
  home.sessionVariables = {
    PATH = "$HOME/.local/bin:$PATH";
  };
  home.enableNixpkgsReleaseCheck = false;
  home.username = "mark";
  home.homeDirectory = "/home/mark";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  xdg.configFile."fontconfig/conf.d/10-hm-fonts.conf".force = true;
}
