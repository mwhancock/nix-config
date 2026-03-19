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

  services.pipewire.wireplumber.extraConfig = {
    "99-alsa-soft-mixer" = {
      "monitor.alsa.rules" =[
        {
          # Enable soft-mixer for all outputs (Fixes global volume control)
          matches =[
            { "node.name" = "~alsa_output.*"; }
          ];
          actions = {
            "update-props" = {
              "api.alsa.soft-mixer" = true;
            };
          };
        }
        {
          # Disable soft-mixer for inputs (Prevents mic breakage)
          matches =[
            { "node.name" = "~alsa_input.*"; }
          ];
          actions = {
            "update-props" = {
              "api.alsa.soft-mixer" = false;
            };
          };
        }
      ];
    };
  };
}
