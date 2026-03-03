{ config, pkgs, ... }:

{
  home.enableNixpkgsReleaseCheck = false;
  home.username = "mark";
  home.homeDirectory = "/home/mark";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;

  home.packages = with pkgs; [

    #archives
    zip
    xz
    unzip
    p7zip

    fastfetch

    #networking tools
    nmap
    socat
    ipcalc
    traceroute

    #monitoring tools
    btop
    iftop
    strace
    ltrace

    #system tools
    pciutils
    sysstat
    usbutils

  ];

  programs.git = {
    enable = true;
    settings.user.name = "mark";
    settings.user.email = "mwhancock@proton.me";
  };

}
