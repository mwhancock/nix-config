# Services, filtered by the migration review.
#
# Kept:   libvirt, tailscale, printing, ssh
# Dropped: VPN, Kafka, Waydroid, Ollama, Flatpak, Portal
{ config, lib, pkgs, ... }:

{
  # Kept. NOTE the group addition is additive to the base list in
  # hosts/nixos/configuration.nix; NixOS merges list options, so this does not
  # replace it.
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  users.users.mark.extraGroups = [ "libvirtd" ];

  # Kept.
  services.tailscale.enable = true;
  networking.networkmanager.unmanaged = [ "interface-name:tailscale0" ];

  # Kept. Also in the live system's own configuration.nix, so this is a
  # no-op relative to what is already running.
  services.printing.enable = true;
  services.openssh.enable = true;

  # ---------------------------------------------------------------------------
  # CPU power management: auto-cpufreq, and why PPD had to go.
  #
  # These two cannot both run. This is not a "two daemons fight" soft warning,
  # it is a hard systemd dependency -- power-profiles-daemon.service ships with
  #
  #   Conflicts=tuned.service tlp.service auto-cpufreq.service system76-power.service
  #
  # and the nixpkgs auto-cpufreq module installs auto-cpufreq.service under
  # multi-user.target. Starting one stops the other, so enabling both leaves the
  # loser torn down on every boot. Nothing warns about it: the NixOS module for
  # auto-cpufreq (nixos/modules/services/hardware/auto-cpufreq.nix) has no
  # assertion against any other power manager.
  #
  # PPD was active before this, at profile `balanced` -- governor `powersave`
  # with EPP `balance_performance` under amd-pstate-epp. auto-cpufreq takes over
  # that same job, which is the point: one daemon, not two.
  #
  # What is lost: `powerprofilesctl` stops working, and so does the GNOME/
  # Omarchy power-profile switcher, which is a frontend to PPD. Runtime profile
  # switching is now auto-cpufreq's automatic AC/battery detection instead, and
  # there is no manual override.
  #
  # Why these values are the ones this hardware can actually take. Read from
  # sysfs, not assumed:
  #
  #   scaling_available_governors                performance powersave
  #     Only these two. amd-pstate-epp has no ondemand/conservative, so the
  #     governor pair below is the whole menu.
  #   energy_performance_available_preferences   default performance
  #                                             balance_performance
  #                                             balance_power power custom
  #   platform_profile_choices                   does not exist
  #     This laptop exposes no ACPI platform profile, so `platform_profile` is
  #     deliberately NOT set. auto-cpufreq would try to write
  #     /sys/firmware/acpi/platform_profile on every AC/battery change and fail
  #     it.
  #   energy_performance_available_biases        does not exist
  #     EPB is intel_pstate only. `energy_perf_bias` is likewise not set.
  #
  # Governor and EPP are paired deliberately rather than left to auto-cpufreq's
  # defaults, because amd_pstate is in `active` mode here (amd_pstate/status
  # says "active", and scaling_available_governors is the active-mode pair). In
  # active mode the governor constrains EPP: `performance` forces EPP to
  # `performance`, so asking for anything else on AC is self-contradictory.
  # `powersave` on battery is what makes EPP `power` meaningful.
  #
  # turbo = "never" on battery is auto-cpufreq's own default and the aggressive
  # end of it. It is the single largest battery win here, and the cost is real
  # responsiveness away from the charger. Raise it to "auto" if that feels too
  # slow -- it is one line.
  #
  # battery_device is pinned because auto-cpufreq otherwise takes the first
  # battery it finds, and this machine has three power_supply entries: ACAD,
  # BATT, and hid_0018:222A:550D.0001_battery_13 (a hidpp battery reported by a
  # Bluetooth device, not the pack). Pinning BATT is the internal one and makes
  # the AC/battery switch deterministic instead of enumeration-order dependent.
  services.power-profiles-daemon.enable = false;

  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        energy_performance_preference = "performance";
        turbo = "auto";
      };
      battery = {
        battery_device = "BATT";
        governor = "powersave";
        energy_performance_preference = "power";
        turbo = "never";
      };
    };
  };

  # ---------------------------------------------------------------------------
  # Dropped, with reasons -- these are the ones that would actually break
  # something if imported, so they are worth writing down:
  #
  #   services.flatpak
  #     The old file declared four flatpaks AND imported nix-flatpak.nixosModules
  #     from the flake. Nixarchy has its own flatpak handling. Three layers for
  #     one subsystem.
  #
  #   xdg.portal
  #     Set extraPortals to gtk/gnome/wlr and defaulted to "gnome", while
  #     nixarchy manages the portal for Hyprland. It also wrote XDG_DATA_DIRS
  #     pointing at a store path that does not exist:
  #       ...hq58p9cjbkrfzandg0fgrlj07jgi8wpv-xdg-desktop-portal-gtk-1.15.3/share
  #     That was the ONLY place hosts/mfv3's mkForce'd XDG_DATA_DIRS mattered;
  #     the rest of the forced list replaced Nixpkgs' defaults with five
  #     entries. Dropping the module drops the mkForce with it.
  #
  #   services.ollama
  #     Superseded by programs.nixarchy.localAi, which stays enabled.
  #
  #   services.apache-kafka
  #     clusterId was the literal placeholder "xxxxxxxxxxxxxxxxxxxxxx".
  #
  #   networking.wg-quick.interfaces.wg0
  #     Dropped as instructed, but see below -- this is not a cleanup.
  #
  #   virtualisation.waydroid
  #     Was already enable = false.

  # ---------------------------------------------------------------------------
  # The WireGuard key that was committed to this repository.
  #
  # This is not a note about tidiness. nixModules/services/vpn.nix contained a
  # plaintext `privateKey`, committed in 70634cc4 and pushed to origin/main,
  # which is a public repository. The key must be treated as compromised and
  # rotated at the server regardless of whether the interface is ever used
  # again. Removing the file does not un-publish the history.
  #
  # If a VPN is wanted later, the key belongs in agenix or sops-nix, never in
  # the tree.
}