#!/bin/bash

# Exit when error occurs
set -e

current_dir="$(dirname "$0")"

# Enable user services
user_services=(
  'syncthing'
)
systemctl --user enable "${user_services[@]}"

# Copy system-wide setting files
sudo cp "$current_dir/config/lightdm-gtk-greeter.conf" \
     '/etc/lightdm/lightdm-gtk-greeter.conf'
sudo cp "$current_dir/config/30-touchpad.conf" \
     '/etc/X11/xorg.conf.d/30-touchpad.conf'

# Enable system services
system_services=(
  'NetworkManager'
  'docker'
  'lightdm'
  'man-db.timer'
  'systemd-timesyncd'
  'tlp'
  'tlp-sleep'
)
sudo systemctl enable "${system_services[@]}"

# Add user to docker group
sudo gpasswd -a "$USER" docker
