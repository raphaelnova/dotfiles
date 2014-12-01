#!/bin/bash

find ./home/ -maxdepth 1 \! -path "./home/" -print0 | while read -rd $'\0' FILE; do
  FILENAME="$(basename $FILE)"
  ln -fs ~/dotfiles/home/$FILENAME ~/
done

