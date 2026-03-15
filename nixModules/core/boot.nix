{ ... }:
{
  boot.loader = {
    limine = {
      enable = true;
      maxGenerations = 10;
    };
    timeout = 5;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "snd-hda-intel.model=alc245-fixup-bass-hp-dac" ];
}
