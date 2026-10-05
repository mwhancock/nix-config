# niri-solo-width: lone tiled window expands to full width, shrinks to 50% when peers appear.
# Niri has no native setting for this, so it runs as a user event-stream daemon.
{ lib
, python3
, writeShellScript
, makeWrapper
, runCommand
, ...
}:

let
  script = ./niri-solo-width.py;

  wrapped = runCommand "niri-solo-width" {
    nativeBuildInputs = [ makeWrapper ];
    passthru = { inherit script; };
  } ''
    mkdir -p $out/bin
    makeWrapper ${python3}/bin/python3 $out/bin/niri-solo-width \
      --add-flags "${script}"
    install -D -m 644 ${script} $out/share/niri-solo-width/niri-solo-width.py
  '';
in
wrapped
