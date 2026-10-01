# Fonts that OnlyOffice Desktop Editors can actually see.
#
# THE BUG THIS EXISTS TO WORK AROUND
#
# OnlyOffice does not build its font list through fontconfig. It walks a fixed
# list of directories itself and reads what it finds. The evidence is on this
# machine, in the app's own log:
#
#   ~/.local/share/onlyoffice/desktopeditors/data/fonts/fonts.log
#
# which lists every font file the app loaded on its last start. Every line in it
# points inside
#
#   /nix/store/...-onlyoffice-desktopeditors-9.1.0/share/desktopeditors/fonts/
#
# -- OnlyOffice's own bundled directory, which contains exactly nine families
# (ASC, Asana, Caladea, Carlito, Open Sans, OpenSymbol). That is not a subset of
# the system's 1189 registered fonts. It is the whole list.
#
# The same directory appears in OnlyOffice's own bug tracker, and the NixOS wiki
# documents the same conclusion with the same workaround:
#
#   https://github.com/NixOS/nixpkgs/issues/373521   installed fonts not listed
#   https://github.com/NixOS/nixpkgs/issues/488518   fonts.packages does not help
#   https://discourse.nixos.org/t/onlyoffice-adding-font-declaratively/19903
#   https://wiki.nixos.org/wiki/ONLYOFFICE           "copy them to the user
#                                                      directory"
#
# Registering a font with fonts.packages does not help. Neither does enabling
# fontDir, which only creates /run/current-system/sw/share/fonts -- a directory
# OnlyOffice never looks in. The nixpkgs maintainers and the wiki agree the one
# workaround that works is ~/.local/share/fonts.
#
# WHY THE SANDBOX IS NOT THE PROBLEM
#
# It is reasonable to suspect OnlyOffice's bubblewrap wrapper, which binds /nix
# and symlinks the host's /etc/fonts. It is not the cause. The wrapper does bind
# /nix, so a font package in the store is reachable from inside the sandbox; the
# app simply never asks for it. (There IS a separate, unrelated wart in there:
# the FHS root's bundled fontconfig is too old to parse fontconfig 3 syntax, so
# it spams "invalid attribute 'xsi:nil'" against 48-guessfamily.conf. That only
# affects anything that calls fontconfig inside the sandbox, which -- per the
# log above -- the font list is not.)
#
# WHY AN ACTIVATION SCRIPT RATHER THAN home.file
#
# home.file links one file at a time from the store, so a package holding 122
# font files would need 122 entries, written out by hand and re-written whenever
# the package's file list changes. The copy has to dereference anyway: several
# font packages use symlinks inside share/fonts, and a symlink into /nix/store
# is still readable from the home directory, but the list of files is not
# something to maintain by hand.
#
# So the packages below are copied. That is normally the wrong thing to do in
# Nix, and it is done here because the app requires a real directory of real
# files that is not in the store -- the same reason the dotfiles tree is
# vendored and symlinked in hosts/nixos/home.nix rather than generated.
#
# It stays declarative in the way that matters: the package list lives in
# modules/packages/default.nix, and this file mirrors exactly that list. Removing
# a font there removes it here on the next activation, because the manifest
# check below rebuilds the directory whenever the package set changes.
{ lib, pkgs, ... }:

let
  # The same list as fonts.packages in modules/packages/default.nix. Kept here
  # as a literal rather than read across the module boundary: this is a Home
  # Manager module and cannot read the NixOS system config, and osConfig would
  # only add an import cycle and a rebuild of the whole system to learn a list
  # that is eight entries long.
  fontPackages = with pkgs; [
    inter
    source-sans
    source-serif
    source-code-pro
    roboto
    lato
    merriweather
    hack-font
  ];

  storePaths = map toString fontPackages;

  # Newline-joined, so the manifest comparison below is exact and order
  # sensitive -- reordering the list rebuilds the directory, which is correct,
  # since the per-package subdirectory names change with it.
  manifest = lib.concatStringsSep "\n" storePaths;
in
{
  # Deliberately no home.file here.
  #
  # An earlier draft put a .keep in nixos-fonts/ so the directory would exist
  # before the first copy. That gives two owners of one path: Home Manager links
  # the .keep in, then the script below deletes it with rm -rf and the next
  # activation finds it missing and puts it back. It works, and it churns. The
  # script creates the directory itself, which is the one-owner arrangement
  # home.nix already argues for with ~/.config/fish.
  # lib.hm.dag.entryAfter, not lib.stringAfter.
  #
  # This Home Manager revision replaced the string helpers with an explicit DAG:
  # isEntry is `e ? data && e ? after && e ? before`, and home.activation is an
  # attrsOf submodule over that shape. lib.stringAfter still returns the old
  # { after, data; } pair, which does not typecheck here -- it fails at
  # evaluation with "A definition for option ...onlyOfficeFonts.data is not of
  # type 'string'". Every module in home-manager/modules/ uses lib.hm.dag.
  home.activation.onlyOfficeFonts = lib.hm.dag.entryAfter [ "installPackages" ]
    ''
      fonts_dir="$HOME/.local/share/fonts"
      managed="$fonts_dir/nixos-fonts"

      # The manifest lives in ~/.cache, NOT inside the managed directory.
      # OnlyOffice recurses the whole tree and hands every file it finds to the
      # font parser, so a manifest sitting in there gets logged as a font it
      # failed to read:
      #
      #   /home/mark/.local/share/fonts/nixos-fonts/.packages
      #
      # Harmless -- nothing loads from it -- but it is noise in fonts.log, which
      # is the file to read when diagnosing exactly this problem, so it stays
      # out. ~/.cache is also where a marker of this kind belongs.
      state="$HOME/.cache/nixos-fonts.packages"

      mkdir -p "$managed" "$(dirname "$state")"

      # Only rebuild when the package list actually changed. Copying 231 font
      # files and re-running fc-cache on every single home-manager switch,
      # including the ones triggered by unrelated config edits, is not worth it.
      current=""
      if [ -f "$state" ]; then
        current="$(cat "$state")"
      fi

      if [ "$current" != "${manifest}" ]; then
        # Start from empty so a font dropped from modules/packages/default.nix
        # disappears from OnlyOffice too, instead of lingering forever.
        #
        # The chmod is not optional. cp -rL below copies the store's mode with
        # it, and everything in /nix/store is r--r--r-- and dr-xr-xr-x, so the
        # per-package subdirectories come out 0555. rm -rf then cannot unlink
        # anything inside them -- "Permission denied" on every file, the
        # activation fails, and the directory is left half deleted. An earlier
        # version of this file did the plain rm and did exactly that on the
        # second rebuild. This is also why the NixOS wiki's version of this
        # workaround ends with `chmod 644` on everything it copies.
        chmod -R u+w "$managed" 2>/dev/null || true
        rm -rf "$managed"
        mkdir -p "$managed"

        for pkg in ${lib.concatStringsSep " " storePaths}; do
          if [ -d "$pkg/share/fonts" ]; then
            # One subdirectory per package. OnlyOffice recurses, and its own
            # bundle uses subdirectories (asana/, caladea/, crosextra/), so this
            # is the layout it already handles. It also means two packages
            # shipping a file of the same name cannot clobber each other.
            dest="$managed/$(basename "$pkg")"
            mkdir -p "$dest"
            cp -rL "$pkg/share/fonts/." "$dest/"
          fi
        done

        # Make the copies writable by their owner, so this directory behaves
        # like a hand-made ~/.local/share/fonts rather than a second /nix/store
        # that the user cannot clean up without sudo.
        chmod -R u+w "$managed"

        printf '%s' "${manifest}" > "$state"

        # fontconfig scans ~/.local/share/fonts on its own, but only after it
        # builds a cache for the directory. Without this the first application
        # to look pays for scanning every file here.
        if command -v fc-cache >/dev/null 2>&1; then
          fc-cache -f "$fonts_dir" >/dev/null 2>&1 || true
        fi
      fi
    '';
}
