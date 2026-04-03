{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../../nixModules/packages/system-packages.nix
    ../../nixModules/services/ssh.nix
    ../../nixModules/services/tailscale.nix
    ../../nixModules/users/mark.nix
  ];

  networking.hostName = "server";
  time.timeZone = "America/St_Johns";
  programs.fish.enable = true;

  services.openssh.enable = true;
  users.users.mark = {
    isNormalUser = true;
    extraGroups = ["wheel" "docker"];
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
          subvolume = {
            "home" = {};
            "storage" = {};
            "root" = {};
          };
          snapshot_dir = ".snapshots";
        };
      };
    };
  };

  system.stateVersion = "24.11";
}
