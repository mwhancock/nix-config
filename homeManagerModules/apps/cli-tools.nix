{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zip
    xz
    unzip
    p7zip
    nmap
    socat
    ipcalc
    traceroute
    fastfetch
    btop
    iftop
    strace
    ltrace
    pciutils
    #quickshell
    sysstat
    usbutils
  ];
}
