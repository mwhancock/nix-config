{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    zip xz unzip p7zip nmap socat ipcalc traceroute gemini-cli
    fastfetch btop iftop strace ltrace pciutils sysstat usbutils
    nodejs mosquitto yazi aider-chat
  ];

  home.sessionVariables = {
    PUPPETEER_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
  };

  home.file.".config/yazi".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/yazi/.config/yazi";
  home.file.".config/aider".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/aider/.config/aider";
}
