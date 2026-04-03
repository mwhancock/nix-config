{ ... }: {
  imports = [
    ../../homeManagerModules/apps/nvim/
    ../../homeManagerModules/apps/cli-tools.nix
    ../../homeManagerModules/apps/neovim.nix
    ../../homeManagerModules/core/git-config.nix
    ../../homeManagerModules/core/shell.nix
    ../../nixModules/packages/system-packages.nix
    ../../nixModules/services/ssh.nix
    ../../nixModules/services/tailscale.nix
    ../../nixModules/services/virtualbox.nix
    ../../nixModules/services/vpn.nix
    ../../nixModules/services/printing.nix
    ../../nixModules/users/mark.nix
    
  ];

  networking.hostName = "pangolin";
  time.timeZone = "America/St_Johns";

  services.openssh.enable = true;
  users.users.mark = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [ 
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKDq4G5XbhpGlKxF/FHBqs2qs8M+r+Z/qKJeiWS+c21y mwhancock@proton.me" 
    ];
  };

  services.btrfs.autoScrub.enable = true;
  services.btrbk = {
    instances.local = {
      onCalendar = "daily";
      settings = {
        snapshot_preserve_min = "2d";
        snapshot_preserve = "7d 4w";
        volume."/" = {
          subvolume = { "home" = { }; "storage" = { }; "root" = { }; };
          snapshot_dir = ".snapshots";
        };
      };
    };
  };

  system.stateVersion = "24.11"; 
}
