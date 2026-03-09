{ pkgs, inputs, ... }:
{
  imports = [ ../../homeManagerModules/default.nix ];

  home.enableNixpkgsReleaseCheck = false;
  home.username = "mark";
  home.homeDirectory = "/home/mark";
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
  xdg.configFile."fontconfig/conf.d/10-hm-fonts.conf".force = true;

  home.sessionVariables = {
    PATH = "$HOME/.local/bin:$PATH";
  };

  home.packages = with pkgs; [

    #archive management
    zip
    xz
    unzip
    p7zip

    #desktop apps
    nextcloud-client
    nemo
    foliate
    pdfarranger
    vesktop
    steam
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    postman

    #networking tools
    nmap
    socat
    ipcalc
    traceroute

    #system tools
    fastfetch
    btop
    iftop
    strace
    ltrace
    pciutils
    sysstat
    usbutils
  ];
}
