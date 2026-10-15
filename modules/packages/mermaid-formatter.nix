# mermaid-formatter — https://github.com/chenyanchen/mermaid-formatter
#
# A formatter for Mermaid diagram syntax. Not in nixpkgs, and upstream publishes
# only to npm; the package is zero-dependency with a prebuilt dist/, so the
# published tarball is fetched and its dist/cli.js wrapped with node rather than
# rebuilt from source (which would drag in the whole TypeScript toolchain for no
# benefit). Pinned to 0.3.0; bump `version` and `hash` together.
#
# Provides:
#
#   mermaidfmt   format a .mmd from a path or stdin to stdout
#
# This is the CLI half. The Neovim side is the <leader>om keymap in
# dotfiles/neovim/.config/nvim/lua/config/keymaps.lua, which runs it over every
# ```mermaid fence in the buffer, on demand -- deliberately not on save.
#
# Why not on save: mermaid-formatter's ER support is thin. It flattens the
# indentation inside an `entity { ... }` block (attributes are pulled out to one
# level and the closing brace is left at column 0), so autoformatting would make
# an ER diagram less readable every time it was written. Sequence and flowchart
# blocks format well; ER does not. Triggering it by hand keeps the choice.
{ lib
, stdenv
, fetchurl
, nodejs
, makeWrapper
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mermaid-formatter";
  version = "0.3.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/mermaid-formatter/-/mermaid-formatter-${finalAttrs.version}.tgz";
    hash = "sha256-PKv0cFTu7lr8U5raoGhF/xbjEx1cQEvZ9xhSY51jFHQ=";
  };

  # npm tarballs unpack to a single package/ directory and ship built JS; there
  # is nothing to compile.
  dontBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/mermaid-formatter $out/bin
    cp -r . $out/lib/mermaid-formatter/

    makeWrapper ${lib.getExe nodejs} $out/bin/mermaidfmt \
      --add-flags $out/lib/mermaid-formatter/dist/cli.js

    runHook postInstall
  '';

  meta = {
    description = "Formatter for Mermaid diagram syntax";
    homepage = "https://github.com/chenyanchen/mermaid-formatter";
    license = lib.licenses.mit;
    mainProgram = "mermaidfmt";
    platforms = lib.platforms.unix;
  };
})
