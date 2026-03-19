{...}: {
  boot.loader = {
    limine = {
      enable = true;
      maxGenerations = 10;
    };
    timeout = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = ["snd-hda-intel.model=alc256-asus-aio"];
  boot.blacklistedKernelModules = ["snd_acp_pci" "snd_acp70"];
}
