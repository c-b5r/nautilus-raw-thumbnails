#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

# ────────────────────────────────────────────────────────────────────────
# Usage & Sanity Checks
# ────────────────────────────────────────────────────────────────────────
INPUT=${1:?Usage: $0 <input.CR3> <output.png>}
OUTPUT=${2:?Usage: $0 <input.CR3> <output.png>}

[[ -r $INPUT ]] || {
  echo "ERROR: Cannot read input file '$INPUT'" >&2
  exit 1
}

# ────────────────────────────────────────────────────────────────────────
# Derive Base Name (no dir, no extension)
# ────────────────────────────────────────────────────────────────────────
FNAME=${INPUT##*/}
BASE=${FNAME%.*}

# ────────────────────────────────────────────────────────────────────────
# 1) Extract embedded thumbnail into /tmp
#    -l /tmp tells exiv2 “put previews there”
# ────────────────────────────────────────────────────────────────────────
exiv2 -l /tmp -ep1 "$INPUT"

# ────────────────────────────────────────────────────────────────────────
# 2) Locate the preview file via shell-glob
# ────────────────────────────────────────────────────────────────────────
PREVIEWS=( /tmp/"${BASE}-preview1."* )
if (( ${#PREVIEWS[@]} == 0 )); then
  echo "ERROR: No embedded thumbnail found in '$INPUT'" >&2
  exit 1
fi

# ────────────────────────────────────────────────────────────────────────
# 3) Convert & auto-orient
# ────────────────────────────────────────────────────────────────────────
magick "${PREVIEWS[0]}" -auto-orient "$OUTPUT"

# ────────────────────────────────────────────────────────────────────────
# 4) Clean up
# ────────────────────────────────────────────────────────────────────────
rm -f -- "${PREVIEWS[0]}"

exit 0
