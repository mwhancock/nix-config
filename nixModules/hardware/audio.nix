{ ... }:
{
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.etc."wireplumber/wireplumber.conf.d/alsa-soft-mixer.conf".text = ''
    monitor.alsa.rules = [
      {
        matches = [
          {
            device.name = "alsa_card.pci-0000_c4_00.6"
          }
        ]
        actions = {
          update-props = {
            api.alsa.soft-mixer = true
          }
        }
      },
      {
        matches = [
          {
            device.name = "~alsa_card.*"
            node.name = "~alsa_input.*"
          }
        ]
        actions = {
          update-props = {
            api.alsa.soft-mixer = false
          }
        }
      }
    ]
  '';
}
