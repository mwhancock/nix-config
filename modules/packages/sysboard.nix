# sysboard — https://github.com/System64fumo/sysboard
#
# An on-screen keyboard for wlroots-style Wayland compositors: it sits at the
# bottom through gtk4-layer-shell, sends keystrokes through
# zwp_virtual_keyboard_v1, and — the part this machine cares about — shows and
# hides itself by listening to zwp_input_method_v2's activate/deactivate, which
# the compositor emits exactly when a text field gains and loses focus.
#
# Not in nixpkgs, and upstream ships no flake.nix, so it is built from the
# source tree here. Pinned to a commit; bump `rev` and `hash` together.
#
# Three things about the build deserve naming:
#
#   * The Makefile installs its default config under PREFIX and derives PREFIX
#     from /usr/local, but main.cpp looks for that config at the absolute path
#     /usr/share/sys64/board/config.conf. That path cannot exist in a store, so
#     the patch below rewrites the compiled-in literal to this derivation's own
#     $out/share. Without it sysboard starts, finds no config anywhere, prints
#     "No config available" and exits 1.
#
#   * The Makefile's src/git_info.hpp rule shells out to `git` inside the source
#     tree to fill in its version string. fetchFromGitHub provides no .git
#     directory, so the header is written directly below; the rule has no
#     prerequisites, so make leaves an existing file alone.
#
#   * The installed executable dlopen()s libsysboard.so by bare name. It is not
#     reliably found through the executable's own RUNPATH, so the wrapper puts
#     $out/lib on LD_LIBRARY_PATH.
{ lib
, stdenv
, fetchFromGitHub
, pkg-config
, wrapGAppsHook4
, gtk4
, gtkmm4
, gtk4-layer-shell
, wayland
, wayland-scanner
}:

stdenv.mkDerivation rec {
  pname = "sysboard";
  version = "unstable-2025-11-23";

  src = fetchFromGitHub {
    owner = "System64fumo";
    repo = "sysboard";
    rev = "1a032fb4dd76f3f5496955d293eab2ea90f7fc15";
    hash = "sha256-wSx1YyzZvcuCscSSQi+nrvvIh0iFjLDQgnBXN80KfFU=";
  };

  nativeBuildInputs = [ pkg-config wrapGAppsHook4 wayland-scanner ];
  buildInputs = [ gtk4 gtkmm4 gtk4-layer-shell wayland ];

  postPatch = ''
    substituteInPlace src/main.cpp \
      --replace-fail '/usr/share/sys64/board' "$out/share/sys64/board"

    echo '#define GIT_COMMIT_MESSAGE "sysboard, built by nixpkgs"' > src/git_info.hpp
    echo '#define GIT_COMMIT_DATE "2025-11-23"' >> src/git_info.hpp
  '';

  # The Makefile derives BINDIR/DATADIR from PREFIX, and `?=` means an exported
  # PREFIX wins over the built-in /usr/local.
  preBuild = ''
    export PREFIX=$out
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix LD_LIBRARY_PATH : "$out/lib")
  '';

  meta = {
    description = "Simple virtual keyboard for Wayland";
    homepage = "https://github.com/System64fumo/sysboard";
    license = lib.licenses.gpl3Only;
    mainProgram = "sysboard";
    platforms = lib.platforms.linux;
  };
}
