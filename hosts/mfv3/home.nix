{ pkgs, ... }:
{
  imports = [
    ../../homeManagerModules/default.nix
  ];
  home.sessionVariables = {
    PATH = "$HOME/.local/bin:$PATH";
  };
  home.enableNixpkgsReleaseCheck = false;
  #nixGL.vulkan.enable = true;
  home.username = "mark";
  home.homeDirectory = "/home/mark";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  programs.quickshell.enable = true;
  xdg.configFile."fontconfig/conf.d/10-hm-fonts.conf".force = true;
  xdg.desktopEntries.nemo = {
    name = "Nemo";
    exec = "${pkgs.nemo-with-extensions}/bin/nemo";
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = [ "nemo.desktop" ];
      "application/x-gnome-saved-search" = [ "nemo.desktop" ];
    };
  };
}
