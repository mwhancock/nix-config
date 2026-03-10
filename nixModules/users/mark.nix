{ pkgs, ... }:
{
  users.users.mark = {
    isNormalUser = true;
    description = "mark";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "mark"
      "disk"
      "root"
      "audio"
    ];
  };
}
