{...}: {
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

   boot.extraModprobeConfig = ''
    options snd-hda-intel model=alc256-asus-aio
  '';

  services.pipewire.wireplumber.extraConfig."alsa-soft-mixer"."monitor.alsa.rules" = [
    {
      actions.update-props."api.alsa.soft-mixer" = true;
      matches = [
        {
          "device.name" = "~alsa_card.*";
        }
      ];
    }
    {
      actions.update-props."api.alsa.soft-mixer" = false;
      matches = [
        {
          "device.name" = "~alsa_card.*";
          "node.name" = "~alsa_input.*";
        }
      ];
    }
    {
      actions.update-props."session.suspend-timeout-seconds" = "0";
      matches = [
        {
          "node.name" = "~alsa_input.*";
        }
        {
          "node.name" = "~alsa_output.*";
        }
      ];
    }
  ];
}
