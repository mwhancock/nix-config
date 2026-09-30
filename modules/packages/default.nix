# The package set chosen during the migration review.
#
# Cut from hosts/mfv3's system-packages.nix (40 entries) down to what was
# actually asked for. Everything below that was NOT chosen is listed at the
# bottom with the reason, so a later "why isn't X here" has an answer that is
# not just archaeology.
{ pkgs, ... }:

let
  # Not in nixpkgs, so built from source here.
  gmc = pkgs.callPackage ./gmc.nix { };
in

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };

  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  environment.systemPackages = with pkgs; [
    # Toolchain
    git
    gmc
    gcc
    clang
    clang-tools
    cmake
    gnumake
    pkg-config
    cargo
    rustc
    rustup
    clippy
    jdk
    maven
    gradle
    python3
    nh
    nixd

    # Embedded / electronics
    arduino-cli
    arduino-ide
    arduino-language-server
    platformio
    fritzing
    qucs-s
    kicad
    freecad

    # Graphics / games / documents
    godot
    vlc
    texliveFull

    # Shell and desktop utilities
    wl-clipboard
    grim
    slurp
    swappy
    alsa-tools
    alsa-firmware
    adwaita-icon-theme
    gnome-themes-extra
    hicolor-icon-theme
    gvfs
    net-tools
    nil
    nixpkgs-fmt
    input-remapper
    tree
    wget
    jetbrains-mono

    # From the live system's own packages list in /etc/nixos.
    neovim
    curl
  ];

  # ---------------------------------------------------------------------------
  # Deliberately not carried over from hosts/mfv3:
  #
  #   haskellPackages.kafka, python314Packages.kafka-python
  #       Only useful with the Kafka service, which was dropped.
  #   rocmPackages.rpp
  #       ROCm runtime, several GB. Not requested.
  #   gnufreetype-hinting, lilypond, fulltex, pandoc, ghostty, ...
  #       Not requested.
  #   swaybg, swaylock, swayidle
  #       Sway components. This is a Hyprland machine running nixarchy, which
  #       ships its own lock/background/idle handling. Installing Sway's would
  #       fight it.
  #   xwayland-satellite
  #       Sway's XWayland wrapper. Nixarchy handles XWayland.
  #   dsearch, zen-browser
  #       Not requested.
  #   libsecret
  #       Present transitively via nixarchy; not needed explicitly.
}
