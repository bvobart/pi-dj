#!/bin/bash -e
# Patches some files that specify base packages for the OS and graphical environment.
# For some reason, I wasn't able to generate a working patch file for these changes...

cd stage3/00-install-packages

rm -rf 00-debconf 00-packages 00-packages-nr

cat <<EOF > 00-packages
alsa-utils
arandr
ffmpeg
fonts-droid-fallback
fonts-liberation2
git
libgl1-mesa-dri libgles1 libgles2-mesa xcompmgr
policykit-1
rfkill
udevil
EOF

cat <<EOF > 00-packages-nr
xserver-xorg xinit xserver-xorg-video-fbdev xserver-xorg-video-fbturbo
mousepad
zenity
lightdm xterm i3 i3status
libasound-dev
EOF
