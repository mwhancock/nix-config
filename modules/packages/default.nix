# The package set chosen during the migration review.
#
# Cut from hosts/mfv3's system-packages.nix (40 entries) down to what was
# actually asked for. Everything below that was NOT chosen is listed at the
# bottom with the reason, so a later "why isn't X here" has an answer that is
# not just archaeology.
{ pkgs, inputs, ... }:

let
  # Not in nixpkgs, so built from source here.
  gmc = pkgs.callPackage ./gmc.nix { };

  # sysboard: the GTK4 on-screen keyboard, also built from source. sysboard-ctl
  # is the supervisor that runs it only while no keyboard is attached; it takes
  # the sysboard binary as an argument, so bind it once here and share it.
  sysboard = pkgs.callPackage ./sysboard.nix { };
  sysboard-ctl = pkgs.callPackage ./sysboard-ctl.nix { inherit sysboard; };

  # LumineCapture: Wayland screenshot/annotation tool with OCR, built from the
  # flake's git input since it is not in nixpkgs.
  lumineCapture = pkgs.callPackage ./lumine-capture.nix {
    lumine-capture = inputs.lumine-capture;
  };
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
  # libtinfo and libstdc++ are for foreign binaries generally; most toolchains
  # that are not built by Nix expect those two by name.
  #
  # NOTE: Unity is NOT served by this list. Unity Hub ships as a buildFHSEnv
  # sandbox (bubblewrap), and the Editor it launches inherits that sandbox,
  # where /lib64 is the FHS glibc loader rather than nix-ld. NIX_LD_LIBRARY_PATH
  # is therefore ignored there. The missing Unity libraries are added to the
  # Hub's FHS environment by the overlay below instead.
  #
  # NIX_LD_LIBRARY_PATH is read at login: rebuild, then log out and back in
  # before retrying the run.
  programs.nix-ld.libraries = with pkgs; [
    libxrender
    libxtst
    libtinfo
    gccNGPackages.libstdcxx
  ];

  # ---------------------------------------------------------------------------
  # envfs: the FHS fallback path.
  #
  # /bin and /usr/bin on this system are envfs mounts, not directories. envfs
  # resolves a path like /usr/bin/curl from the PATH of the *calling* process,
  # and falls back to a fixed "fallback path" directory when the caller's PATH
  # has no match.
  #
  # Homebrew resets PATH to /usr/bin:/bin:/usr/sbin:/sbin for every process it
  # spawns -- the "filter the user environment" block in Homebrew's bin/brew --
  # and then re-execs itself with `env -i`. Under that PATH almost nothing
  # resolves: the names in the system closure conflict (four different
  # coreutils builds each ship bin/ls), and envfs drops conflicted names from
  # its union. Only "env" and "sh" survive, because those are the two things
  # the fallback path happens to contain. Homebrew could not even re-exec
  # itself:
  #
  #     env: '/bin/bash': No such file or directory
  #
  # The fallback path is consulted exactly when the PATH lookup fails, so
  # populating it restores the standard FHS utilities for any caller whose
  # PATH does not cover them. That is what this option exists for.
  #
  # The list is what Homebrew shells out to by bare name: coreutils for the
  # file and text plumbing, the archivers for unpacking bottles, and a
  # compiler plus make for the formulae that have no bottle and are built from
  # source.
  #
  # A few are less obvious and are here because Homebrew failed without them:
  #
  #   flock    Homebrew takes a lock file before it will update or install
  #            anything, and it takes it with flock(2), or ruby, or python.
  #            Without one of those it refuses to run at all.
  #   ldd      Homebrew's vendor-install.sh reads the system glibc version
  #            from `ldd --version` before it will unpack portable ruby.
  #   ssh      This machine's global git config rewrites every
  #            https://github.com/ URL to git@github.com: (url.insteadOf), so
  #            Homebrew's `brew update` fetches over SSH and needs an ssh
  #            binary. It also needs the agent, which the session provides.
  #   openssl, shasum
  #            Checksums for the vendored tarballs.
  #
  # curl and git are deliberately NOT here, even though they are the two tools
  # Homebrew cares about most. See the brew.env block below for why, and for
  # how Homebrew is pointed at them instead.
  #
  # make and gcc are here, and only here. No language toolchain is installed
  # system-wide (see the environment.systemPackages comment below); each
  # project brings its own. Homebrew, though, needs a compiler at a fixed
  # path to build from source, and its build steps run with PATH set to the
  # FHS default.
  services.envfs.extraFallbackPathCommands = ''
    for f in ${pkgs.coreutils}/bin/*; do
      ln -sf "$f" $out/
    done
    ln -sf ${pkgs.bash}/bin/bash $out/bash
    ln -sf ${pkgs.gnused}/bin/sed $out/sed
    ln -sf ${pkgs.gawk}/bin/awk $out/awk
    ln -sf ${pkgs.gnugrep}/bin/grep $out/grep
    ln -sf ${pkgs.gnugrep}/bin/egrep $out/egrep
    ln -sf ${pkgs.gnugrep}/bin/fgrep $out/fgrep
    ln -sf ${pkgs.findutils}/bin/find $out/find
    ln -sf ${pkgs.findutils}/bin/xargs $out/xargs
    ln -sf ${pkgs.gnutar}/bin/tar $out/tar
    ln -sf ${pkgs.gzip}/bin/gzip $out/gzip
    ln -sf ${pkgs.bzip2}/bin/bzip2 $out/bzip2
    ln -sf ${pkgs.xz}/bin/xz $out/xz
    ln -sf ${pkgs.zstd}/bin/zstd $out/zstd
    ln -sf ${pkgs.unzip}/bin/unzip $out/unzip
    ln -sf ${pkgs.gnupatch}/bin/patch $out/patch
    ln -sf ${pkgs.diffutils}/bin/diff $out/diff
    ln -sf ${pkgs.which}/bin/which $out/which
    ln -sf ${pkgs.file}/bin/file $out/file
    ln -sf ${pkgs.python3}/bin/python3 $out/python3
    ln -sf ${pkgs.perl}/bin/perl $out/perl
    ln -sf ${pkgs.perl}/bin/shasum $out/shasum
    ln -sf ${pkgs.openssl}/bin/openssl $out/openssl
    ln -sf ${pkgs.util-linux}/bin/flock $out/flock
    ln -sf ${pkgs.openssh}/bin/ssh $out/ssh
    ln -sf ${pkgs.openssh}/bin/scp $out/scp
    ln -sf ${pkgs.openssh}/bin/sftp $out/sftp
    ln -sf ${pkgs.glibc.bin}/bin/ldd $out/ldd
    ln -sf ${pkgs.glibc.bin}/bin/getconf $out/getconf
    ln -sf ${pkgs.glibc.bin}/bin/iconv $out/iconv
    ln -sf ${pkgs.glibc.bin}/bin/locale $out/locale
    ln -sf ${pkgs.gnumake}/bin/make $out/make
    ln -sf ${pkgs.gnumake}/bin/gmake $out/gmake
    ln -sf ${pkgs.gcc}/bin/gcc $out/gcc
    ln -sf ${pkgs.gcc}/bin/cc $out/cc
    ln -sf ${pkgs.binutils}/bin/ld $out/ld
    ln -sf ${pkgs.binutils}/bin/as $out/as
    ln -sf ${pkgs.binutils}/bin/ar $out/ar
    ln -sf ${pkgs.binutils}/bin/nm $out/nm
    ln -sf ${pkgs.binutils}/bin/ranlib $out/ranlib
    ln -sf ${pkgs.binutils}/bin/strip $out/strip
    ln -sf ${pkgs.binutils}/bin/objcopy $out/objcopy
    ln -sf ${pkgs.pkg-config}/bin/pkg-config $out/pkg-config
  '';

  # ---------------------------------------------------------------------------
  # Homebrew's curl and git.
  #
  # Homebrew does not run curl and git from PATH. It resolves each one once,
  # at startup, and every later use goes through the absolute path it picked.
  # The candidates it considers, in order, are the brewed copy, then
  # /usr/bin/curl, then whatever HOMEBREW_CURL_PATH points at -- but the
  # /usr/bin candidate is only skipped if it fails the check, so a working
  # /usr/bin/curl wins over the suggestion.
  #
  # On this system /usr/bin/curl cannot be that candidate. envfs resolves
  # /usr/bin/<name> by searching the calling process's PATH, and Homebrew
  # puts its own shim directory first in PATH:
  #
  #   /home/linuxbrew/.linuxbrew/Homebrew/Library/Homebrew/shims/shared
  #
  # So from inside Homebrew, /usr/bin/curl resolves to Homebrew's curl shim.
  # The shim checks whether it is about to exec itself, by reading the link
  # target of the binary it was given -- and envfs answers that readlink with
  # the same PATH-resolved answer, the shim. The shim therefore decides it
  # would be exec'ing itself, refuses, and every download fails with
  #
  #   Error: Failed to get curl path
  #
  # The fix is to have Homebrew use a curl and git that live outside /usr/bin,
  # where envfs does not rewrite them.
  #
  # Two things have to happen together for that. HOMEBREW_CURL_PATH is only a
  # suggestion, and it is consulted only when the /usr/bin candidate fails --
  # so curl and git are deliberately left out of the envfs fallback path
  # above, which is what makes /usr/bin/curl fail that check. And the
  # suggestion itself has to be a path envfs leaves alone, which a store path
  # is; the system profile would do too, but naming the packages here keeps
  # the two in step with the nixpkgs pin.
  #
  # /etc/homebrew/brew.env is Homebrew's own system-wide environment file. It
  # is read by Homebrew's bin/brew on every run, and because these are
  # HOMEBREW_-prefixed they survive the `env -i` that Homebrew re-execs
  # itself with.
  environment.etc."homebrew/brew.env".text = ''
    HOMEBREW_CURL_PATH=${pkgs.curl}/bin/curl
    HOMEBREW_GIT_PATH=${pkgs.git}/bin/git
  '';

  # The envfs mount has to be remounted for a changed fallback path to take
  # effect. The mount unit is generated from fileSystems, so a changed
  # fallback path shows up as a changed usr-bin.mount; nixos-rebuild reloads
  # that unit during the switch, but systemd does not remount on a reload, and
  # the running FUSE daemon keeps the fallback path it was started with.
  # Without this the config and the running system disagree, silently, until
  # the next reboot.
  #
  # The daemon-reload comes first on purpose. This snippet runs before
  # systemd re-reads the units it is about to change, so without it the
  # restart would pick up the unit as it was and put the old fallback path
  # back.
  system.activationScripts.envfs = ''
    ${pkgs.systemd}/bin/systemctl daemon-reload
    ${pkgs.systemd}/bin/systemctl restart usr-bin.mount
  '';

  # Unity Hub runs both itself and the Editor it launches inside a
  # buildFHSEnv sandbox. That sandbox carries libstdc++ but not libtinfo, so
  # the Editor's UnityShaderCompiler helper dies at startup with
  #   libtinfo.so.6: cannot open shared object file
  # and Unity reports the shader-compiler IPC timeout (0x80000008 Timed out).
  # extraPkgs puts a package's libraries into the FHS environment's
  # /usr/lib64, which is where the sandboxed glibc looks. Use `libtinfo`, not
  # `ncurses`: plain ncurses only ships a libtinfo.so.6 *alias* to
  # libncursesw.so.6, whose SONAME is libncursesw.so.6, so ldconfig (which
  # indexes by SONAME) never puts libtinfo.so.6 in the cache and the loader
  # still fails. libtinfo is the ncurses build with a real termlib, and its
  # libtinfo.so.6 has SONAME libtinfo.so.6.
  nixpkgs.overlays = [
    (final: prev: {
      unityhub = prev.unityhub.override {
        extraPkgs = p: [ p.libtinfo ];
      };

      # Packet Tracer 9 ships Qt 6.8 and, under XWayland, renders its UI at
      # 100% -- on this 1.5x panel its menus and toolbar come out about
      # two-thirds the size of every native app. Qt 6 dropped the two DPI
      # variables Packet Tracer's own main.cpp sets (QT_DEVICE_PIXEL_RATIO and
      # QT_AUTO_SCREEN_SCALE_FACTOR are not in the bundled libQt6Gui), so the
      # only lever left is QT_SCALE_FACTOR, which Qt applies as-is on top of
      # whatever scale it already computed. 1.5 is the panel's niri scale, so
      # Packet Tracer ends up the same physical size as everything else.
      #
      # Wrapped rather than overridden in a .desktop file so the variable is
      # set however the app is started: menu, .pka association or terminal.
      cisco-packet-tracer_9 = prev.symlinkJoin {
        name = "cisco-packet-tracer-9-scaled";
        paths = [ prev.cisco-packet-tracer_9 ];
        nativeBuildInputs = [ prev.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/packettracer9 --set QT_SCALE_FACTOR 1.5
        '';
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    # Niri solo-width daemon: a lone tiled window expands to full width, and
    # shrinks to a share when peers appear. Niri has no config for this, so the
    # behaviour lives in a user service instead -- see
    # systemd.user.services.niri-solo-width in hosts/nixos/home.nix for why,
    # and for the measurements taken against the running compositor.
    (callPackage ./niri-solo-width.nix { })

    # On-screen keyboard for the tablet, plus the supervisor that gates it on
    # no real keyboard being attached. Started as a user service -- see
    # systemd.user.services.sysboard-ctl in hosts/nixos/home.nix for why the
    # gating is external to sysboard.
    sysboard
    sysboard-ctl

    # Toolchain
    #
    # No language toolchain is installed system-wide. Every project declares
    # its own: the base shells live in ~/dotfiles/devshells (rust, java,
    # kotlin, cc, node, python) and a project imports the one it needs. What
    # stays here is used at the prompt or by the desktop rather than to build
    # a particular repository.
    git
    gmc
    python3
    nh
    nixd
    # Linter for the Nix language server wired up in Neovim. LazyVim's nix extra
    # runs statix on every .nix buffer through nvim-lint, and with nothing on PATH
    # every save printed "Error running statix: ENOENT". nixfmt (the formatter the
    # same extra uses) already comes in from elsewhere.
    statix

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

    # mermaid-cli (mmdc): renders ```mermaid fences for Neovim's diagram.nvim
    # plugin (dotfiles/neovim/.config/nvim/lua/plugins/diagram.lua) and the
    # mermaid step inside md-export. The nixpkgs wrapper bundles its own
    # Chromium for Puppeteer, so no browser needs to be on PATH.
    mermaid-cli

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
    # LumineCapture, bound to SUPER+P (see ~/.config/hypr/bindings.lua).
    # grim/slurp/swappy stay: they back the PRINT-key flow and omarchy's
    # capture scripts.
    lumineCapture
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

    # WinApps: launch Windows apps (Word, Excel, ...) from the Linux desktop
    # as if native. The package bundles FreeRDP 3, dialog, netcat and friends,
    # and wraps `winapps`/`winapps-setup` with LIBVIRT_DEFAULT_URI set. It needs
    # a running Windows VM called RDPWindows (see the WinApps libvirt docs);
    # until that VM exists the binaries are installed but have nothing to talk
    # to. winapps-launcher adds the system-tray app launcher.
    inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system}.winapps
    inputs.winapps.packages.${pkgs.stdenv.hostPlatform.system}.winapps-launcher

    # Remote desktop client for the WinApps VM: VNC to the dockur/noVNC port
    # when keyboard input through the browser is flaky, and RDP once Windows is
    # fully set up.
    remmina
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
