{ ... }:
{
  services.auto-cpufreq.enable = true;
  services.power-profiles-daemon.enable = false;
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";

}
