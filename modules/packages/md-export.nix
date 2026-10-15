# md-export: render a Markdown file to PDF or DOCX, diagrams included.
#
# This is the program behind Neovim's <leader>op / <leader>od keymaps
# (dotfiles/neovim/.config/nvim/lua/config/keymaps.lua), which shell out to
#
#   md-export <file> <pdf|docx> [output]
#
# The keymaps were written against this tool but it was never committed
# anywhere, so every export died with
#
#   ENOENT: no such file or directory (cmd): 'md-export'
#
# because vim.system throws when it cannot spawn the program -- which is the
# "pile of errors" the LazyVim config shows in place of a result.
#
# What it does: every ```mermaid fenced block is pulled out, rendered by
# mermaid-cli (mmdc), and replaced with an image reference; the rewritten
# document is then handed to Pandoc.
#
#   pdf   Pandoc's Typst engine. Diagrams as SVG (vector); $...$ and $$...$$
#         math handled natively by Typst. No LaTeX distribution needed.
#   docx  Pandoc's native writer. Diagrams as PNG; equations as Word OMML.
#
# Two details that are easy to get wrong, both found by testing on this
# machine:
#
#   htmlLabels=false in the mermaid config. Mermaid's default SVG draws node
#   labels inside <foreignObject>, which Typst refuses to render properly (it
#   warns "image contains foreign object" and the labels come out wrong).
#   Turning it off makes mermaid emit plain SVG <text>.
#
#   mainfont. Pandoc's Typst template leaves the font list empty unless
#   mainfont is set, and Typst then aborts with "font fallback list must not be
#   empty". DejaVu Sans is the default because it is present here and covers
#   the math glyphs; MD_EXPORT_FONT overrides it.
#
# The body lives in md-export.sh so it can be tested as an ordinary script and
# keeps its `$` spellings readable; it is read here rather than inlined.
{ writeShellApplication
, pandoc
, typst
, mermaid-cli
, gawk
, coreutils
}:

writeShellApplication {
  name = "md-export";

  # pandoc, typst and mmdc are looked up on PATH by the script; awk for the
  # fence extraction, coreutils for mktemp/realpath. Chromium is deliberately
  # not listed: nixpkgs' mermaid-cli wrapper already points Puppeteer at its
  # own, so no browser needs to be on PATH.
  runtimeInputs = [ pandoc typst mermaid-cli gawk coreutils ];

  text = builtins.readFile ./md-export.sh;

  meta.description = "Export Markdown (with Mermaid diagrams) to PDF or DOCX";
}
