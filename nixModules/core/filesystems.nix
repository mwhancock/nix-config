{ lib, ... }:
{
  fileSystems."/" = lib.mkForce {
    device = "/dev/nvme0n1p2";
    fsType = "btrfs";
    options = [
      "subvol=@root"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/home" = lib.mkForce {
    device = "/dev/nvme0n1p2";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/nix" = lib.mkForce {
    device = "/dev/nvme0n1p2";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/var/log" = lib.mkForce {
    device = "/dev/nvme0n1p2";
    fsType = "btrfs";
    options = [
      "subvol=@log"
      "compress=zstd"
      "noatime"
    ];
    neededForBoot = true;
  };

  fileSystems."/boot" = lib.mkForce {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };
}
