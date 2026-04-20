{
  programs.fish = {
    enable = true;

    # Shell aliases
    shellAliases = {
      ll = "ls -l";
      vpnup = "sudo systemctl start wg-quick-wg0.service";
      vpndown = "sudo systemctl stop wg-quick-wg0.service";
      la = "ls -a";
      lla = "ls -la";
      gs = "git status";
      gp = "git push";
      gl = "git log --oneline --graph";
      gd = "git diff";
      cb-config = "nix run nixpkgs#repomix -- --copy --ignore '.git/**,result/**,*.pdf,*.png'";
      conf = "cd ~/nixos-config && vi";
      nix-rebuild = "find ~/.config -name '*.bak' -exec rm -rf {} + 2>/dev/null; find ~/ -maxdepth 1 -name '*.bak' -exec rm -rf {} + 2>/dev/null; sudo nixos-rebuild switch --flake ~/nixos-config";
      nix-diff = "sudo nixos-rebuild list-generations";
      nix-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      home-rebuild = "home-manager switch --flake ~/nixos-config";
      fix-audio = "nix shell nixpkgs#alsa-utils --command sudo alsactl restore";
      iron = "ssh -t sauron@mountdoom.taile9eef.ts.net 'tmux attach || tmux new-session -s nvim nvim'";
    };

    # Abbreviations (expand after space - Fish-specific)
    shellAbbrs = {
      nix-up = "sudo nixos-rebuild switch --flake ~/nixos-config";
      nix-dry = "cd ~/nixos-config; and sudo nixos-rebuild dry-activate --flake .";
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
      set -gx EDITOR nvim
      set -gx VISUAL nvim
      set -gx TERMINAL ghostty
      set -g fish_greeting "Welcome back, mark! λ"
    '';
  };
}
