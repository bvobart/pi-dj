#!/bin/bash -e
# This script is meant to be run inside a DietPi image and expects to be within this Git repository (as it will look for certain files there)
# It installs the necessary packages and configs on top of DietPi to create the OS image for Pi-DJ.
# TODO: figure out how I can experiment with the resulting images without having to flash them onto an actual Pi.

HERE="$(dirname "$(realpath "$0")")"
REPO_DIR=$(realpath "$HERE/..")

source "$HERE/utils.sh"

## Create pi-dj user and delete default dietpi user
default_username=pi-dj
default_password=pidj
useradd -m -G sudo -s "$(which zsh)" -p $default_password $default_username
# userdel -r dietpi # not sure if the dietpi user can be removed: https://github.com/MichaIng/DietPi/issues/2807#issuecomment-493044119

## Configure /boot/dietpi.txt
# TODO: instruct users about dietpi-wifi.txt to pre-enter WiFicredentials.

set_dietpi_config AUTO_SETUP_LOCALE en_GB.UTF-8
set_dietpi_config AUTO_SETUP_KEYBOARD_LAYOUT gb
set_dietpi_config AUTO_SETUP_TIMEZONE Europe/Amsterdam
set_dietpi_config AUTO_SETUP_NET_ETHERNET_ENABLED 1
set_dietpi_config AUTO_SETUP_NET_WIFI_ENABLED 1
set_dietpi_config AUTO_SETUP_NET_WIFI_COUNTRY_CODE NL
set_dietpi_config AUTO_SETUP_NET_HOSTNAME Pi-DJ
set_dietpi_config AUTO_SETUP_BOOT_WAIT_FOR_NETWORK 0
set_dietpi_config AUTO_SETUP_SSH_SERVER_INDEX -2 # Select OpenSSH instead of Dropbear as default SSH server
# set_dietpi_config AUTO_SETUP_SSH_PUBKEY asdasdasfasd # TODO: allow user to provide a public key to be added to the authorized_keys file
set_dietpi_config AUTO_SETUP_BROWSER_INDEX -1 # Select Firefox as default browser
set_dietpi_config AUTO_SETUP_AUTOSTART_TARGET_INDEX 2 # Select X11 Desktop autologin as default autostart target
set_dietpi_config AUTO_SETUP_AUTOSTART_LOGIN_USER $default_username
set_dietpi_config AUTO_SETUP_AUTOMATED 1
set_dietpi_config AUTO_SETUP_GLOBAL_PASSWORD pidj
set_dietpi_config CONFIG_CHECK_DIETPI_UPDATES 1 # Enable daily check for DietPi updates. 0=disable | 1=enable
set_dietpi_config CONFIG_CHECK_APT_UPDATES 1 # Enable daily check for APT package updates: 0=disable | 1=check only | 2=check and upgrade automatically
set_dietpi_config CONFIG_NTP_MODE 2 # Network time sync: 0=disabled | 1=boot only | 2=boot + daily | 3=boot + hourly | 4=Daemon + Drift
set_dietpi_config SOFTWARE_DISABLE_SSH_PASSWORD_LOGINS root # Disable SSH password logins, e.g. when using pubkey authentication
                                                            #   0=Allow password logins for all users, including root
                                                            #   root=Disable password login for root user only
                                                            #   1=Disable password logins for all users, assure that you have a valid SSH key applied!
##### other DietPi.txt stuff to configure later
#
# Custom Script (pre-networking and pre-DietPi install)
# - Allows you to automatically execute a custom script before network is up on first boot.
# - Copy your script to /boot/Automation_Custom_PreScript.sh and it will be executed automatically.
# - Executed script log: /var/tmp/dietpi/logs/dietpi-automation_custom_prescript.log
#### TODO: this is useful for automatically setting AUTO_SETUP_NET_WIFI_ENABLED 1 only when dietpi-wifi.txt is present
#
# Custom Script (post-networking and post-DietPi install)
# - Allows you to automatically execute a custom script at the end of DietPi install.
# - Option 0 = Copy your script to /boot/Automation_Custom_Script.sh and it will be executed automatically.
# - Option 1 = Host your script online, then use e.g. AUTO_SETUP_CUSTOM_SCRIPT_EXEC=https://myweb.com/myscript.sh and it will be downloaded and ecuted automatically.
# - Executed script log: /var/tmp/dietpi/logs/dietpi-automation_custom_script.log
# AUTO_SETUP_CUSTOM_SCRIPT_EXEC=0
#
#

## Install all packages needed for a usable desktop environment
# 5: Alsa
# 6: X.Org
# 7: FFmpeg
# 170: UnRAR
# 17: Git
# 188: Go 
# 67: Firefox
dietpi-software install 5 6 7 170 17 188 67
# install i3 and dependencies
apt install -y i3 polybar onboard fonts-roboto fonts-font-awesome dunst rofi

# install some useful CLI tools for maintenance
apt install -y alacritty zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s "$(which zsh)"
git config pull.rebase true

## Configure desktop environment & applications
"$REPO_DIR"/desktop/install.sh


# TODO: install other packages required for desktop environment
# Goal for next time: get a usable and pretty UI with i3, polybar, kitty, rofi, onboard, dunst

# TODO: install Mixxx
# TODO: install mixxx-folders2crates
# TODO: add Pioneered skin and set as default
