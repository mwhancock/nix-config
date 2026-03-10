{ ... }:
{
  boot.loader = {
    limine.enable = true;
    timeout = 5;
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "snd-hda-intel.model=alc245-fixup-bass-hp-dac" ];
}
