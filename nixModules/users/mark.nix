{pkgs, ...}: {
  users.users.mark = {
    isNormalUser = true;
    description = "mark";
    shell = pkgs.fish;
    extraGroups = [
      "audio"
      "networkmanager"
      "wheel"
      "mark"
      "disk"
      "root"
    ];
  };
}
