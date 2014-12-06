#!/bin/bash

cd "$(dirname "$0")"

FOLDER="$(pwd)/home/"
find "$FOLDER" -maxdepth 1 \! -path "$FOLDER" -exec ln -fs "{}" ~/ \;

