#!/bin/bash

# Example: rm-dl-annotated.sh "/Super Cool Research Paper I Scribbled All Over"
# Generates: ./"Super Cool Research Paper (annotated).pdf" with the scribbles on top of the original PDF

# Dependencies:
# * rmapi https://github.com/juruen/rmapi
# * rM2svg https://github.com/reHackable/maxio/blob/master/tools/rM2svg
# * rsvg-convert
# * pdfunite
# * pdftk
# * pdftoppm (if you use cropping)

set -o errexit

function print_help() {
  echo "rm-dl-annotated.sh [-v] [--help | -h] path/to/cloud/PDF"
  echo "where:
    -h or --help  show this help text
    --keep        keep work directory (for debugging)
    -v            verbose mode"
}

function die_with_usage() {
  print_help
  exit 1
}

# Check arguments

VERBOSE=
KEEP_WORK=
REMOTE_PATH=

while test $# -gt 0
do
  case "$1" in
    -v) VERBOSE=yes
      ;;
    --keep) KEEP_WORK=yes
      ;;
    -h) print_help
      exit 0
      ;;
    --help) print_help
      exit 0
      ;;
    *) REMOTE_PATH="$1"
      ;;
  esac
  shift
done

if [ -z "$REMOTE_PATH" ]; then
  die_with_usage
  exit 1
fi

# Do our work in a temporary directory

# https://stackoverflow.com/a/246128
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WORK_DIR=$(mktemp -d)
OBJECT_NAME=$(basename "$REMOTE_PATH")

pushd "$WORK_DIR" >/dev/null

if [ "$VERBOSE" = "yes" ] || [ "$KEEP_WORK" = "yes"]; then
  echo "Created temporary directory \"$WORK_DIR\""
fi

# Download the given document using the ReMarkable Cloud API

rmapi get "$REMOTE_PATH" >/dev/null
unzip "$OBJECT_NAME.zip" >/dev/null

UUID=$(basename "$(ls ./*.pdf)" .pdf)

if [ ! -f "./$UUID.lines" ]; then
  echo "PDF is not annotated. Exiting."

  if [ -z "$KEEP_WORK" ]; then
    rm -r "$WORK_DIR"
  fi

  exit 0
fi

CONTENT_FILE=$WORK_DIR/$UUID.content

# Check if the PDF has been cropped
IS_TRANSFORMED=false
if [ "$("$SCRIPT_DIR"/is-transformed.py "$CONTENT_FILE")" = "Yes" ]; then
  IS_TRANSFORMED=true
fi

# Convert the .lines file containing our scribbles to SVGs and then a PDF

rM2svg --coloured_annotations -i "./$UUID.lines" -o "./$UUID"

if [ $IS_TRANSFORMED = true ]; then
  echo "PDF is cropped."
  echo "Applying crop to SVGs..."
fi

PAGES=()
for svg in ./*.svg; do
  if [ $IS_TRANSFORMED = true ]; then
    # Apply the transformation (crop) to the SVGs so the annotations end up in the right places
    "$SCRIPT_DIR/apply-svg-transform.py" "$svg" "$UUID.content" "$svg"
  fi

  # Convert SVG to PDF
  PAGE_NAME=$(basename "$svg" .svg)
  rsvg-convert -f pdf -o "$PAGE_NAME.pdf" "$PAGE_NAME.svg"
  PAGES+=($PAGE_NAME.pdf)
done

pdfunite "${PAGES[@]}" "$UUID"_annotations.pdf

# Transform (crop) the original PDF if necessary
if [ $IS_TRANSFORMED = true ]; then
  echo "Applying crop to PDF..."

  IMAGE_DIR=pdf_images
  mkdir "$IMAGE_DIR"
  pdftoppm "$UUID".pdf "$IMAGE_DIR/$UUID" -png

  PAGES=()
  for pdf_image in "$IMAGE_DIR"/*.png; do
    "$SCRIPT_DIR/apply-image-transform.py" "$pdf_image" "$UUID".content "$pdf_image"
    PAGES+=($pdf_image)
  done

  convert "${PAGES[@]}" "$UUID".pdf
fi

# Layer the annotations onto the original PDF

OUTPUT_PDF="$OBJECT_NAME (annotated).pdf"
pdftk "$UUID".pdf multistamp "$UUID"_annotations.pdf output "$OUTPUT_PDF"

popd >/dev/null
cp "$WORK_DIR"/"$OUTPUT_PDF" .

if [ -z "$KEEP_WORK" ]; then
  rm -r "$WORK_DIR"
fi

echo Generated "\"$OUTPUT_PDF\""
