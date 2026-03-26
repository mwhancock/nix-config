{pkgs, ...}: {
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
    vimPlugins.markdown-preview-nvim
    mermaid-filter
    nodejs
  ];

  home.sessionVariables = {
    PUPPETEER_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
  };
}
