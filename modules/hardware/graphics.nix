# The OpenGL/EGL dispatch libraries, for clients that are not built by Nix.
#
# hardware.graphics.enable already links mesa's vendor drivers into
# /run/opengl-driver/lib -- libGLX_mesa.so, libEGL_mesa.so, dri/, gbm/. What it
# does NOT put there on this nixpkgs pin is libglvnd, which owns the
# libGL.so.1 / libEGL.so.1 / libGLESv2.so.2 entry points every client asks for
# by soname. Those names have no provider anywhere on the search path, so
# anything that loads GL at runtime rather than linking it at build time dies:
#
#   libskiko-linux-x64.so: libGL.so.1: cannot open shared object file
#
# That is exactly what a Compose Multiplatform desktop app does: skiko ships a
# prebuilt .so inside a jar and dlopen()s it on the first frame.
#
# nix-ld cannot help here and neither can NIX_LD_LIBRARY_PATH. nix-ld works by
# occupying /lib64/ld-linux-x86-64.so.2, and the JVM in question is nixpkgs'
# own -- patched to the glibc loader in the store -- so it never consults
# either variable. Only LD_LIBRARY_PATH does, which is why the reproduction is
#
#   LD_LIBRARY_PATH=/run/opengl-driver/lib ./gradlew :desktopApp:run
#
# and why it only works once libGL.so.1 is actually in that directory.
#
# Nothing here is specific to that one application: every GL client that
# resolves by soname -- a downloaded binary, a JVM app, a Flatpak's host
# integration -- gets the same benefit. extraPackages merges into the driver
# environment rather than replacing it, so mesa and the AMD/ROCm libraries
# already in it are unaffected.
{ pkgs, ... }:

{
  hardware.graphics.extraPackages = with pkgs; [
    libglvnd
  ];
}
