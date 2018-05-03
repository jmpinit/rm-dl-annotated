#!/bin/bash

# Example: rm-dl-annotated.sh "/Super Cool Research Paper I Scribbled All Over"
# Generates: ./"Super Cool Research Paper (annotated).pdf" with the scribbles on top of the original PDF

# Dependencies:
# * rmapi https://github.com/juruen/rmapi
# * rM2svg https://github.com/reHackable/maxio/blob/master/tools/rM2svg
# * rsvg-convert
# * pdfunite
# * pdftk

set -o errexit

function die_with_usage() {
  echo "Usage: rm-dl-annotated path/to/cloud/PDF"
  exit 1
}

# Check arguments

if [ "$#" -ne 1 ]; then
  die_with_usage
fi

# Do our work in a temporary directory

WORK_DIR=$(mktemp -d)
REMOTE_PATH="$1"
OBJECT_NAME=$(basename "$REMOTE_PATH")

pushd "$WORK_DIR" >/dev/null

# Download the given document using the ReMarkable Cloud API

rmapi get "$REMOTE_PATH" >/dev/null
unzip "$OBJECT_NAME.zip" >/dev/null

UUID=$(basename "$(ls ./*.pdf)" .pdf)

if [ ! -f "./$UUID.lines" ]; then
  echo "PDF is not annotated. Exiting."
  rm -r "$WORK_DIR"
  exit 0
fi

# Convert the .lines file containing our scribbles to SVGs and then a PDF

rM2svg --coloured_annotations -i "./$UUID.lines" -o "./$UUID"

PAGES=()
for svg in ./*.svg; do
  PAGE_NAME=$(basename "$svg" .svg)
  rsvg-convert -f pdf -o "$PAGE_NAME.pdf" "$PAGE_NAME.svg"
  PAGES+=($PAGE_NAME.pdf)
done

pdfunite "${PAGES[@]}" "$UUID"_annotations.pdf

# Layer the annotations onto the original PDF

OUTPUT_PDF="$OBJECT_NAME (annotated).pdf"
pdftk "$UUID"_annotations.pdf multistamp "$UUID".pdf output "$OUTPUT_PDF"

popd >/dev/null
cp "$WORK_DIR"/"$OUTPUT_PDF" .

rm -r "$WORK_DIR"

echo Generated "$OUTPUT_PDF"
