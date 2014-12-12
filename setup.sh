#!/bin/bash

cd "$(dirname "$0")"

FOLDER="$(pwd)/home/"
find "$FOLDER" -maxdepth 1 \! -path "$FOLDER" -exec ln -fs "{}" ~/ \;

# Setup solarized on pantheon-terminal
. scripts/solarizedDark_pantheon-term_setup.sh
