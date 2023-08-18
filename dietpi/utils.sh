# Set a config value in /boot/dietpi.txt
# Example: set_dietpi_config AUTO_SETUP_TIMEZONE Europe/Amsterdam
function set_dietpi_config() {
  key=$1
  value=$2
  sed -i "s/^$key=.*/$key=$value/" /boot/dietpi.txt
}

# Copy config files from this repo's desktop folder into the Pi-DJ user's home directory
function copy_dotfiles() {
  config_dir=$1
  mkdir -p "/home/$default_username/.config/$config_dir"
  chown -R $default_username:$default_username "/home/$default_username/.config/$config_dir"
  cp -r "$REPO_DIR/desktop/$config_dir" /home/$default_username/.config/
}
