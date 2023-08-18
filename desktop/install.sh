#!/bin/bash
# Installs the .config files for the Pi-DJ desktop environment and its applications.

HERE="$(dirname "$(realpath "$0")")"

USER=${USER:-pi-dj}

function copy_dotfiles() {
  config_dir="$1"
  mkdir -p "/home/$USER/.config/$config_dir"
  chown -R "$USER:$USER" "/home/$USER/.config/$config_dir"
  cp -r "$HERE/$config_dir" "/home/$USER/.config/"
}

copy_dotfiles alacritty
# copy_dotfiles i3
copy_dotfiles rofi
# copy_dotfiles polybar
