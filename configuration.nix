{
  #config,
  pkgs,
  inputs,
  lib,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    #inputs.dms.homeModules.dank-material-shell
    #inputs.niri.homeModules.niri
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.systemPackages = with pkgs; [
    git
    wget
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    #zed-editor
    nil
    nixd
    tree
    impression
  ];

  environment.shells = with pkgs; [ fish ];

  environment.variables = {
    EDITOR = "zed";
    VISUAL = "zed";
    TERMINAL = "ghostty";
    ZEN_PROFILE_DIR = "~/.config/zen zen-backup";
  };

  environment.sessionVariables = {
    XDG_DATA_DIRS = lib.mkAfter [
      "/var/lib/flatpak/exports/share"
      "$HOME/.local/share/flatpak/exports/share"
    ];
  };

  #enable Flatpak support
  services.flatpak = {
    enable = true;

    #add flathub remote
    remotes = [
      {
        name = "flathub";
        location = "https://flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    #define which Flatpaks to install
    packages = [
      "dev.aunetx.deezer"
      "dev.zed.Zed"
    ];

    #auto-update Flatpaks
    update = {
      onActivation = false; # Set true to update on every rebuild
      auto = {
        enable = true;
        onCalendar = "weekly"; # Update weekly
      };
    };
  };

  # Bootloader.
  boot.loader = {
    limine.enable = true;
    timeout = 5;
  };

  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/St_Johns";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_CA.UTF-8";

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true;
        FastConnectable = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
  };

  users.users.mark = {
    isNormalUser = true;
    description = "mark";
    shell = pkgs.fish;
    extraGroups = [
      "networkmanager"
      "wheel"
      "mark"
      "disk"
      "root"
    ];

  };

  # Programs
  programs.fish.enable = true;
  #programs.dank-material-shell.enable = true;
  programs.niri.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List services that you want to enable:
  services.tailscale.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  system.stateVersion = "25.11"; # Did you read the comment?

}
