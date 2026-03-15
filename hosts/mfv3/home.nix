{ ... }:
{
  imports = [
    ../../homeManagerModules/default.nix
  ];
  home.sessionVariables = {
    PATH = "$HOME/.local/bin:$PATH";
  };
  home.enableNixpkgsReleaseCheck = false;
  home.username = "mark";
  home.homeDirectory = "/home/mark";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  programs.quickshell.enable = true;
}
