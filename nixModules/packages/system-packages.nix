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
    gcc
    clang
    clang-tools
    cmake
    input-remapper
    jdk
    python3
    cargo
    rustc
    rustup
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
  ];
}
