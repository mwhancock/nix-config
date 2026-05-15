{pkgs, ...}: {
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
    git
    fritzing
    gcc
    clang
    gnumake
    libsecret
    pkg-config
    clang-tools
    cmake
    input-remapper
    jdk
    python3
    python312Packages.websockets
    python311Packages.pyserial
    python311Packages.paho-mqtt
    cargo
    rustc
    rustup
    clippy
    #android-studio
    nixpkgs-fmt
    nh
    gamemode
    wl-clipboard
    grim
    godot
    gvfs
    gnumake
    rocmPackages.rpp
    slurp
    swappy
    swaybg
    swaylock
    swayidle
    xwayland-satellite
    jetbrains-mono
    wget
    nil
    nixd
    tree
    impression
    alsa-tools
    alsa-firmware
    adwaita-icon-theme
    gnome-themes-extra
    hicolor-icon-theme
    maven
    gradle
    texliveFull
    net-tools
    vlc
    haskellPackages.kafka
    python314Packages.kafka-python-ng
    arduino-ide
    arduino-language-server
    arduino-cli
  ];
}
