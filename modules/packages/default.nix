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

    # Read-only document viewer. The nixpkgs `zathura` attribute is the wrapper
    # that already bundles the plugins wanted here, so it needs no options:
    #   zathura_pdf_mupdf  PDF, and by mimetype also EPUB, MOBI, FictionBook,
    #                      XPS/OXPS, SVG and plain images
    #   zathura_cb         CBZ/CBR/CB7/CBT comics
    #   zathura_djvu       DjVu
    #   zathura_ps         PostScript
    # The mupdf backend is the one that makes epub work, so useMupdf stays at
    # its default of true -- switching to poppler would silently drop epub.
    #
    # This is also the binary the yazi config already calls. Its [open] rules
    # route pdf, epub, cbz/cbr/cb7/cbt, djvu, xps and oxps to `zathura %s`, so
    # those formats open from the file manager as soon as this is installed.
    zathura

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

  # Fonts are registered with fontconfig, not just put on $PATH, so they are
  # declared here rather than appended to systemPackages above. This is what
  # makes them visible to applications that resolve fonts at runtime --
  # OnlyOffice Desktop Editors in particular, which reads the system fontconfig
  # config from inside its bubblewrap sandbox (it binds /nix and symlinks the
  # host's /etc/fonts, so a font package in the store is reachable).
  #
  # `inter` is 4.1, the current upstream release, and is already in the binary
  # cache. It ships Inter.ttc (the whole family, all nine weights) plus
  # InterVariable.ttf and InterVariable-Italic.ttf.
  fonts.packages = with pkgs; [
    inter
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
