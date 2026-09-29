with open("homeManagerModules/apps/cli-tools.nix", "w") as f:
    f.write("""{ config, pkgs, ... }: {
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
""")

with open("homeManagerModules/apps/nvim/default.nix", "w") as f:
    f.write("""{ config, pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [ pandoc tectonic zathura ripgrep fd ];
  };

  home.file.".config/nvim".source = config.lib.file.mkOutOfStoreSymlink "/home/mark/dotfiles/neovim/.config/nvim";
}
""")
