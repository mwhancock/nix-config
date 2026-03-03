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

  programs.ghostty = {
    enable = true;
    settings = {
      #font setting
      font-size = 12;
      font-family = "JetBrainsMono Nerd Font";

      #appearance
      background-opacity = 0.8;
      background-blur = true;
      window-theme = "dark";
      theme = "Gruvbox Dark Hard";
      window-decoration = false;
      window-padding = 0;

      #shell integration
      shell-integration = "fish";

      #cursor
      cursor-style = "block";
      cursor-style-blink = true;

      #behavior
      copy-on-select = true;
    };
  };

  programs.fish = {
    enable = true;

    # Shell aliases (regular aliases)
    shellAliases = {
      ll = "ls -l";
      la = "ls -a";
      lla = "ls -la";
      gs = "git status";
      gp = "git push";
      gl = "git log --oneline --graph";
      gd = "git diff";
      nix-rebuild = "sudo nixos-rebuild switch --flake ~/nixos-config";
      nix-diff = "sudo nixos-rebuild list-generations";
      nix-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
    };

    # Abbreviations (expand after space - Fish-specific)
    shellAbbrs = {
      nix-up = "sudo nixos-rebuild switch --flake ~/nixos-config";
      nix-test = "sudo nixos-rebuild test --flake ~/nixos-config";
      nix-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      ts-up = "sudo tailscale up";
      ts-down = "sudo tailscale down";
      ts-status = "tailscale status";
      nix-update = "cd ~/nixos-config && git pull && nix-rebuild";
      nix-save = "cd ~/nixos-config; and git add .; and git commit -m \"Update: \"(date \"+%Y-%m-%d %H:%M\"); and git push";
      nix-save-manual = "cd ~/nixos-config; and git add .; and git commit; and git push";
    };

    # Additional shell initialization
    shellInit = ''
      set -gx EDITOR zed
      set -gx VISUAL zed
      set -gx TERMINAL ghostty

      # Custom prompt
      set -g fish_greeting "Welcome back, mark! λ"
    '';
  };

  programs.git = {
    enable = true;
    settings.user.name = "mark";
    settings.user.email = "mwhancock@proton.me";
  };

}
