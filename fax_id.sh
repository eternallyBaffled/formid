#!/bin/bash

SERVER="localhost:9998"
FAX_FILE="$1"

# curl to tika to tesseract
# no way to specify we only want the first page ...
# this is going to take a while
# but at least it should work

curl -sS http://${SERVER}/tika --upload-file "${FAX_FILE}" --header "X-Tika-PDFOcrStrategy: ocr_only"

# TODO
# grep number from ocr output
# handle upside down cases
# figure out what tika uses as render params since they work well with tesseract
