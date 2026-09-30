# The laptop: Minisforum V3 (MB8), AMD Ryzen 7 8840U (Hawk Point), 1 TB NVMe.
#
# This host replaced hosts/mfv3, which described a DIFFERENT disk layout and
# must never be built for this machine. Two specific hazards are carried
# forward from that file and are deliberately absent here:
#
#   disko.  hosts/mfv3/disko-config.nix declares /dev/nvme0n1 as btrfs with
#           subvolumes and formatOptions. This machine is ext4 on p2. Running
#           disko against the old file destroys the installation. This host
#           imports hardware-configuration.nix directly and imports no disko
#           module, so `disko` has nothing to act on.
#
#   Limine.  hosts/mfv3 also enabled boot.loader.limine and blacklisted
#           snd_acp_pci while forcing the ASUS "alc256-asus-aio" model. This is
#           an ALC245 laptop whose audio runs through SOF; snd_acp_pci is
#           loaded and in use by snd_amd_acpi_mach right now. The bootloader
#           stays systemd-boot and the audio stack is left alone.
#
# What IS kept from hosts/mfv3: the packages and services chosen during the
# migration review, fish as the login shell, and the personal dotfiles.
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/desktop
    ../../modules/packages
    ../../modules/security
    ../../modules/services
    ../../modules/shell
  ];

  networking.hostName = "nixos";

  # The installer chose this; the hardware config above and this value are the
  # reason the migration does not touch the disk.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  time.timeZone = "America/St_Johns";

  # Kept from the live system, NOT from hosts/mfv3. The old file set
  # i18n.defaultLocale = "en_CA.UTF-8"; the running system never did, and
  # changing locale is not part of a dotfiles migration.
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # ---------------------------------------------------------------- Nixarchy
  #
  # `user` is what puts mark in the `input` group (dictation, game controllers).
  # hosts/mfv3 never set it and its own extraGroups list omitted input, so
  # building the old config would have DROPPED the group the live system has.
  programs.nixarchy = {
    enable = true;
    user = "mark";
    installerManaged = false;

    # This is where nixarchy-apply copies the app selection before rebuilding,
    # and it derives hosts/<name> from `uname -n`. The hostname is "nixos" and
    # this directory is hosts/nixos, so the two agree.
    flake = "/etc/nixos";
  };

  # ----------------------------------------------------------- Local AI
  #
  # Kept per the migration review. The old services/ollama.nix is NOT imported:
  # it ran services.ollama with ollama-vulkan and auto-loaded four models at
  # activation. nixarchy's localAi provides the same daemon plus the opencode
  # and nvim integrations, and the live system already had it enabled.
  programs.nixarchy.localAi.enable = true;

  hardware.amdgpu.opencl.enable = true;

  # ------------------------------------------------------------------ User
  #
  # hosts/mfv3/users/mark.nix listed "root", which is not something a desktop
  # account should hold, and omitted "input". Neither belongs in a dotfiles
  # migration, in opposite directions.
  users.users.mark = {
    isNormalUser = true;
    description = "mark";

    # fish, chosen during the migration review. The live system used bash.
    # `interactiveShellInit` is deliberately not set: the vendored
    # dotfiles/fish/.config/fish/config.fish already handles starship, direnv
    # and zoxide.
    shell = pkgs.fish;

    # extraGroups is the live system's list, verbatim, minus "input".
    #
    # "input" is supplied by programs.nixarchy.user above, which is why the
    # old hosts/mfv3/users/mark.nix -- which omitted it -- would have dropped
    # the group the live system has. Listing it here as well produced
    # extraGroups = [ "input" "wheel" "networkmanager" "input" "libvirtd" ],
    # a duplicate. The membership is identical either way; the duplicate is
    # just noise in every later diff.
    #
    # "libvirtd" is the one addition: you kept libvirt, and virtualisation's
    # qemu groups are not applied to non-root accounts automatically.
    #
    # hosts/mfv3 also listed "root". Deliberately not carried over.
    extraGroups = [ "wheel" "networkmanager" ];
  };

  # No password is declared here. The account's password was set with `passwd`
  # and lives in /etc/shadow; declaring one would either overwrite it or, as
  # hosts/mfv3 did with initialPassword = "1234", reset it to something public.
  # services/openssh keeps the machine reachable either way.

  # stateVersion is the live system's 26.05. hosts/mfv3 said 25.11, which is a
  # DOWNGRADE -- NixOS uses this to decide which migrations still apply, and
  # moving it backwards is never safe.
  system.stateVersion = "26.05";
}