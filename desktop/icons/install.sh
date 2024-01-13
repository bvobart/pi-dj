#!/bin/bash
set -e

# Install into system-wide icons directory if running as root, otherwise install into user's home directory
icons_dir=/usr/share/icons
if [[ "$(whoami)" != "root" ]]; then
  icons_dir=/home/$(whoami)/.local/share/icons
fi

mkdir -p "$icons_dir"

# If candy-icons has already been installed, just update, otherwise install by cloning.
if [[ -e "$icons_dir/candy-icons" ]]; then
  cd "$icons_dir/candy-icons"
  git checkout master > /dev/null
  git pull > /dev/null
else
  git clone --depth 1 https://github.com/EliverLara/candy-icons.git /usr/share/icons/candy-icons
fi
