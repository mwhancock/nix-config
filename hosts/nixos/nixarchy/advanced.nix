# Why: modules/AGENTS.md#anything-at-all
{ ... }:
{
  # Preinstalled applications to leave out, by nixpkgs attribute name.
  #
  # nixarchy ships these as `preinstalls` -- part of the desktop rather than a
  # separate install, so the Install menu cannot deselect one of them. This is
  # the declarative way to take individual apps back out.
  #
  # libreoffice  The whole office suite. Text is written in Obsidian/Markdown,
  #              typed up in omawrite/omacut, and PDFs are read in zathura, so
  #              nothing here needed the office suite installed.
  # obs-studio   Screen recording is already covered by gpu-screen-recorder,
  #              which omarchy binds on its own key.
  # moonlight-qt Game streaming was set up and is not used.
  # kdenlive     Video editing is ffmpeg/mise work; the GUI editor is unused.
  #
  # Foot, Chromium and Evince are NOT excluded here: those are not preinstalls.
  # They arrive as runtimeDeps of the omarchy package itself and are removed in
  # /etc/nixos/modules/desktop/default.nix instead.
  programs.nixarchy.preinstallsExclude = [
    "libreoffice"
    "obs-studio"
    "moonlight-qt"
    "kdenlive"
  ];
}
