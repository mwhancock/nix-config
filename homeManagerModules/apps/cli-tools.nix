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
    gemini-cli
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
