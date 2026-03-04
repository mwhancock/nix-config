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
    gcc
    clang
    cmake
    jdk
    python3
    cargo
    rustc
    rustup
    #android-studio
    postman
    nixpkgs-fmt
    nh
    nemo
    foliate
    pdfarranger
    vesktop
    steam
    gamemode
    virtualbox
    wl-clipboard
    grim
    slurp
    swappy
    swaybg
    swaylock
    swayidle
    xwayland-satellite
    jetbrains-mono
    wget
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    nil
    nixd
    tree
    impression
    alsa-tools
    alsa-firmware
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
    XKB_CONFIG_ROOT = "${pkgs.xkeyboard-config}/etc/X11/xkb";
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
      "com.calibre_ebook.calibre"
    ];

    #auto-update Flatpaks
    update = {
      onActivation = true;
      auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
  };

  # Bootloader.
  boot.loader = {
    limine.enable = true;
    timeout = 5;
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "snd-hda-intel.model=alc245-fixup-bass-hp-dac" ];

  networking.hostName = "nixos"; # Define hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set time zone.
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
      "audio"
    ];

  };

  # Programs
  programs.fish.enable = true;
  #programs.dank-material-shell.enable = true;
  programs.niri.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      alsa-lib
      wayland
      wayland-utils
      libxkbcommon
      vulkan-loader
      mesa
      mesa
      libGL
      libglvnd
      xkeyboard-config
    ];
  };
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List services
  services.tailscale.enable = true;
  services.auto-cpufreq.enable = true;
  services.power-profiles-daemon.enable = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  fileSystems."/" = lib.mkForce {
    device = "/dev/nvme0n1p2";
    fsType = "btrfs";
    options = [
      "subvol=@root"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/home" = lib.mkForce {
    device = "/dev/nvme0n1p2";
    fsType = "btrfs";
    options = [
      "subvol=@home"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/nix" = lib.mkForce {
    device = "/dev/nvme0n1p2";
    fsType = "btrfs";
    options = [
      "subvol=@nix"
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/var/log" = lib.mkForce {
    device = "/dev/nvme0n1p2";
    fsType = "btrfs";
    options = [
      "subvol=@log"
      "compress=zstd"
      "noatime"
    ];
    neededForBoot = true;
  };

  fileSystems."/boot" = lib.mkForce {
    device = "/dev/nvme0n1p1";
    fsType = "vfat";
  };

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  system.stateVersion = "25.11"; # Did you read the comment?

}
