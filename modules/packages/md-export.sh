#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: md-export INPUT.md [pdf|docx] [OUTPUT]

Renders Markdown to PDF (Pandoc + Typst) or DOCX (Pandoc), turning
mermaid fenced code blocks into images first.

  pdf   diagrams as SVG, LaTeX/math via the Typst engine
  docx  diagrams as PNG, equations as native Word OMML

Environment:
  MD_EXPORT_FONT   Typst main font for PDF output (default: DejaVu Sans)
EOF
}

if [ "$#" -lt 1 ]; then
  usage >&2
  exit 2
fi

input=$1
fmt=${2:-pdf}
output=${3:-}

if [ ! -f "$input" ]; then
  printf 'md-export: no such file: %s\n' "$input" >&2
  exit 1
fi

case "$fmt" in
  pdf|docx) ;;
  *)
    printf "md-export: unknown format '%s' (expected pdf or docx)\n" "$fmt" >&2
    exit 2
    ;;
esac

if [ -z "$output" ]; then
  output="${input%.*}.$fmt"
fi

# Absolute paths from here on: the pandoc step below runs from the temp dir so
# that Typst, whose file root is the working directory, resolves the generated
# diagram images against it. realpath -m tolerates the output not existing yet.
input=$(realpath "$input")
output=$(realpath -m "$output")

font=${MD_EXPORT_FONT:-DejaVu Sans}

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Mermaid's default SVG wraps node labels in <foreignObject>, which Typst cannot
# render (it emits "image contains foreign object" and mangles the labels).
# htmlLabels=false makes mermaid emit plain SVG <text> instead.
config="$tmpdir/mermaid.json"
cat > "$config" <<'JSON'
{
  "htmlLabels": false,
  "flowchart": { "htmlLabels": false },
  "theme": "neutral"
}
JSON

ext=svg
if [ "$fmt" = docx ]; then
  ext=png
fi

processed="$tmpdir/processed.md"

# Pull every ```mermaid block out into its own .mmd file and replace the block
# with an image reference. awk writes the extracted diagrams straight into the
# temp dir, so the rewritten markdown and its images sit side by side, and
# records each block's source line range so a failure can name it.
awk -v dir="$tmpdir" -v ext="$ext" '
  BEGIN { keep = 1; n = 0; ranges = sprintf("%s/ranges.tsv", dir) }
  keep == 1 && $0 ~ /^[[:space:]]*```+[[:space:]]*mermaid[[:space:]]*\r?$/ {
    n = n + 1
    keep = 0
    start = NR
    file = sprintf("%s/diagram-%02d.mmd", dir, n)
    next
  }
  keep == 0 && $0 ~ /^[[:space:]]*```+[[:space:]]*\r?$/ {
    keep = 1
    printf("%d\t%d\t%d\n", n, start, NR) >> ranges
    printf("![](diagram-%02d.%s)\n", n, ext)
    next
  }
  keep == 0 { print > file; next }
  { print }
' "$input" > "$processed"

# Render each extracted diagram. A parse error here is a syntax problem in the
# document, not in this tool, so it is reported as such: the diagram's index and
# its line range in the input, then mermaid's own message, and nothing of the
# Puppeteer stack trace below it.
shopt -s nullglob
for f in "$tmpdir"/diagram-*.mmd; do
  name=${f##*/}
  n=${name#diagram-}
  n=${n%.mmd}
  if ! mmdc -i "$f" -o "${f%.mmd}.$ext" -c "$config" -b white >"$f.log" 2>&1; then
    range=$(awk -F'\t' -v want="$n" '$1 == want + 0 { printf "%s-%s", $2, $3 }' "$tmpdir/ranges.tsv")
    printf 'md-export: mermaid diagram %s failed to parse' "$n" >&2
    if [ -n "$range" ]; then
      printf ' (input lines %s)' "$range" >&2
    fi
    printf '.\n' >&2
    awk '/^[[:space:]]+at / { exit } { print }' "$f.log" >&2
    exit 1
  fi
done
shopt -u nullglob

pandoc_args=(
  processed.md
  -o "$output"
  --from markdown
)

if [ "$fmt" = pdf ]; then
  # Pandoc's Typst template leaves the font list empty unless mainfont is set,
  # and Typst then aborts with "font fallback list must not be empty".
  pandoc_args+=( --pdf-engine=typst -V "mainfont=$font" )
fi

# Run from the temp dir so Typst's root is the directory holding processed.md
# and the diagram images it references.
( cd "$tmpdir" && pandoc "${pandoc_args[@]}" )

printf 'Wrote %s\n' "$output"
