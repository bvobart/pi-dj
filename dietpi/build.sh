#!/bin/bash -e
# This script is meant to be run inside a DietPi image and expects to be within this Git repository (as it will look for certain files there)
# It installs the necessary packages and configs on top of DietPi to create the OS image for Pi-DJ.
# TODO: figure out how I can experiment with the resulting images without having to flash them onto an actual Pi.
# Maybe with this? https://unix.stackexchange.com/questions/716226/emulating-arm-v8-to-run-dietpi-in-qemu-for-userspace-software

HERE="$(dirname "$(realpath "$0")")"
REPO_DIR=$(realpath "$HERE/..")

# Ensure /boot/dietpi/.hw_model exists: https://github.com/pguyot/arm-runner-action/issues/91#issuecomment-2091910142
/boot/dietpi/func/dietpi-obtain_hw_model
# Add /boot/dietpi to PATH so we can use the dietpi-* commands
PATH="$PATH:/boot/dietpi"

source "$HERE/utils.sh"

#--------------------------------------------------------------------------------------------------

## Create pi-dj user and delete default dietpi user
log "Creating pi-dj user ..."
default_username=pi-dj
default_password=pidj
useradd -m -G sudo -s "$(which zsh)" -p $default_password $default_username
# userdel -r dietpi # not sure if the dietpi user can be removed: https://github.com/MichaIng/DietPi/issues/2807#issuecomment-493044119

## Configure /boot/dietpi.txt
# TODO: instruct users about dietpi-wifi.txt to pre-enter WiFicredentials.
log "Configuring DietPi /boot/dietpi.txt ..."

set_dietpi_config AUTO_SETUP_LOCALE en_GB.UTF-8
set_dietpi_config AUTO_SETUP_KEYBOARD_LAYOUT gb
set_dietpi_config AUTO_SETUP_TIMEZONE "Europe\/Amsterdam"
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
set_dietpi_config CONFIG_CHECK_CONNECTION_IP "127.0.0.1" # Workaround for installing DietPi software on GitHub Actions runners because Ping doesn't work there. Will be reset after build. https://github.com/pguyot/arm-runner-action/issues/91#issuecomment-2088435969
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
log "Installing DietPi software packages ..."
# 5: Alsa
# 6: X.Org
# 7: FFmpeg
# 170: UnRAR
# 188: Go 
# 67: Firefox
dietpi-software install 5 6 7 170 188 67

# install i3 and dependencies
log "Installing i3 and dependencies ..."
apt-get install -y i3 polybar onboard fonts-roboto fonts-font-awesome dunst rofi

# install some useful CLI tools for maintenance
log "Installing CLI tools (git, kitty, zsh, oh-my-zsh) ..."
apt-get install -y git kitty zsh man less
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
chsh -s "$(which zsh)"
git config pull.rebase true

## Configure desktop environment & applications
log "Configuring desktop environment ..."
"$REPO_DIR"/desktop/install.sh


# TODO: install other packages required for desktop environment
# Goal for next time: get a usable and pretty UI with i3, polybar, kitty, rofi, onboard, dunst

# TODO: install Mixxx
# TODO: install mixxx-folders2crates
# TODO: add Pioneered skin and set as default

log "Finishing up ..."
set_dietpi_config CONFIG_CHECK_CONNECTION_IP "9.9.9.9" # Reset the workaround for installing DietPi software on GitHub Actions runners.

log "Done!"
