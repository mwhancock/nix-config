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

  # Libraries supplied to foreign binaries -- anything downloaded as a tarball
  # rather than built by Nix -- through NIX_LD_LIBRARY_PATH. nixarchy ships the
  # curated base set; a plain assignment here merges with it, so nothing already
  # covered is lost (do not lib.mkForce this option).
  #
  # libxrender and libxtst are the two DT_NEEDED entries of the JetBrains
  # Runtime's libawt_xawt.so that the base set does not carry. The Kotlin
  # Compose plugin downloads that JBR into ~/.cache/JetBrains and runs the app
  # on it, so without them AWT dies at startup with
  #   libXrender.so.1: cannot open shared object file
  # The other X libs in the same .so -- libX11, libXext, libXi -- are already
  # in the base set.
  #
  # NIX_LD_LIBRARY_PATH is read at login: rebuild, then log out and back in
  # before retrying the run.
  programs.nix-ld.libraries = with pkgs; [
    libxrender
    libxtst
  ];

  environment.systemPackages = with pkgs; [
    # Niri solo-width daemon: a lone tiled window expands to full width, and
    # shrinks to a share when peers appear. Niri has no config for this, so the
    # behaviour lives in a user service instead -- see
    # systemd.user.services.niri-solo-width in hosts/nixos/home.nix for why,
    # and for the measurements taken against the running compositor.
    (callPackage ./niri-solo-width.nix { })

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

    # niri's XWayland. niri is enabled as a session (programs.niri in
    # modules/desktop/default.nix) and spawns this binary itself; with it
    # absent niri logs
    #   WARN niri::utils::xwayland::satellite: error spawning xwayland-satellite
    #        ... disabling integration
    # and never sets $DISPLAY, so every X11 client on that session is dead.
    # Cisco Packet Tracer is one: the nixpkgs wrapper hardcodes
    # QT_QPA_PLATFORM=xcb, and its AppImage ships only the linuxfb and xcb Qt
    # platform plugins -- there is no Wayland plugin to fall back to.
    xwayland-satellite

    # Shell and desktop utilities
    wl-clipboard
    grim
    slurp
    swappy
    alsa-tools
    alsa-firmware
    adwaita-icon-theme
    gnome-themes-extra
    # Provides adw-gtk3-dark, the GTK 3 half of libadwaita. Without it, GTK 3
    # apps do not follow the theme, and hyprchroma logs
    # "sync-gtk-theme: adw-gtk3-dark is not installed" on every sync -- once per
    # restart of the looping hyprchromad unit, so it was writing that warning to
    # the journal ~140 times an hour. Listed next to the other icon/theme
    # packages because that is what it is.
    adw-gtk3
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
  #       Was dropped here with the reasoning "Nixarchy handles XWayland",
  #       which is true of Hyprland (it starts Xwayland itself) and irrelevant
  #       to niri, the session actually in use. It is installed now; see the
  #       note on the entry in the list above.
  #   dsearch, zen-browser
  #       Not requested.
  #   libsecret
  #       Present transitively via nixarchy; not needed explicitly.
}
