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
  # declared here rather than appended to systemPackages above.
  #
  # This list is not what makes the fonts reach OnlyOffice -- it could not be.
  # OnlyOffice does not use fontconfig to build its font list on Linux; it walks
  # a handful of fixed directories. The mirror of these same packages into
  # ~/.local/share/fonts is in homeManagerModules/core/fonts.nix, and that is
  # the half that OnlyOffice actually reads. Both halves are needed: fontconfig
  # registration here for everything that does it properly (GTK, Qt, browsers,
  # KiCad, FreeCAD), the mirror for OnlyOffice.
  #
  # Nothing here is free-standing cruft. Omarchy and texmf already contribute
  # Noto, DejaVu, Liberation, FreeFont, URW Gyre and the JetBrains Mono nerd
  # font through its own fonts.packages, and those are left alone.
  #
  # Deliberately NOT included, and why -- this was measured, not guessed:
  #
  #   iosevka    571MB across 54 variable fonts. It would more than double the
  #              footprint of everything else here to add one family.
  #   fira-sans  99MB / 184 files, almost all of it language variants and
  #              italics. 184 near-identical entries in a font picker is the
  #              problem, not the fix.
  #   ibm-plex   The top-level attribute is a set, not a package. It has no
  #              share/fonts at all, so nothing would be copied.
  #   tex-gyre   URW base35 clones, genuinely useful for documents that ask for
  #              Helvetica/Times/Courier by name. Its files live under
  #              share/texmf, not share/fonts, so it is outside the mechanism
  #              in fonts.nix. texliveFull already provides them to LaTeX.
  #   corefonts  Unfree, so it would need an allowUnfreePredicate. Declined
  #              until asked. Caladea and Carlito already ship inside OnlyOffice
  #              and are metric-compatible with Cambria and Calibri.
  fonts.packages = with pkgs; [
    # Inter 4.1, the current upstream release. Inter.ttc carries the whole
    # family at all nine weights, so it is one file rather than nine.
    inter
    # Workhorse document families: a sans, a serif and a mono from one
    # superfamily, so they share a design and pair with each other.
    source-sans
    source-serif
    source-code-pro
    # The sans faces that turn up most often in .docx and .pptx files written
    # elsewhere.
    roboto
    lato
    # A text serif for long-form writing, where source-serif is a bit tight.
    merriweather
    # One more mono, on the other side of DejaVu Sans Mono from Hack.
    hack-font
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
