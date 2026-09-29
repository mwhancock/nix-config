{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    zip xz unzip p7zip nmap socat ipcalc traceroute gemini-cli
    fastfetch btop iftop strace ltrace pciutils sysstat usbutils
    nodejs mosquitto yazi aider-chat
    jellyfin-tui concord aichat bat fzf lazygit starship calibre-tui matcha
  ];

  home.sessionVariables = {
    PUPPETEER_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
  };

  home.file.".config/yazi".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/yazi/.config/yazi";
  home.file.".config/aider".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/aider/.config/aider";
  home.file.".config/bat".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/bat/.config/bat";
  home.file.".config/calibre-tui".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/calibre-tui/.config/calibre-tui";
  home.file.".config/fzf".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/fzf/.config/fzf";
  home.file.".config/lazygit".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/lazygit/.config/lazygit";
  home.file.".config/starship.toml".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/starship/.config/starship.toml";
}
