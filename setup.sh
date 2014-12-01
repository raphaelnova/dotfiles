#!/bin/bash

find ./home/ -maxdepth 1 -print0 | while read -rd $'\0' FILE; do
  FILENAME="$(basename $FILE)"
  ln -fs ~/dotfiles/home/ ~/
done

