#!/bin/bash

###############################################################################################
# Author: 	imatsatsos                                                                        #
# Description:	This script install's a barebones Gnome DE on Void Linux for Intel systems    #
###############################################################################################

###  Description of all installed pkgs  ######################################
# xmirror 			> void util to set xbps mirror, I set it to tier-1 Germany
# void-repo-nonfree > required for intel CPU microcode
# intel-ucode 		> microcode update for intel CPUs
# NetworkManager 	> internet conn  manager, it just works for wifi
# xorg-minimal 		> minimal xorg setup
# dbus 				> needed for apps to talk to the bus
# mesa-dri 			> mesa driver for opengl hw accel
# intel-video-accel > intel gpu driver
# mesa-intel-dri 	> mesa support for intel gpu
# mesa-vulkan-intel > vulkan intel driver
# xdg-utils 		> basic XDG support (xdg-open, etc..)
# xdg-user-dirs 	> XDG support for /downloads, /documents, etc..
# gnome-core 		> minimal gnome
# eog 				> eye of gnome, image viewer
# gnome-tweaks 		> gnome tweaks app
# alacritty 		> terminal
# pipewire 			> new audio engine
# wireplumber 		> new audio session manager
# rtkit 			> pipewire optional dependency, sets realtime priority
# bluez 			> bluetooth support
# gvfs 				> mounting and trash for gnome
# ntfs-3g 			> windows ntfs support
##############################################################################

echo -e "\e[1;32m  This will take some time, go grab a coffee!\e[0m"; sleep 3

echo -e "\e[1;32m  Initial mirror sync, xmirror install, enabling void-repo-nonfree..\e[0m"; sleep 3
sudo xbps-install -Sy xmirror void-repo-nonfree
sudo xmirror --set https://repo-de.voidlinux.org/

echo -e "\e[1;32m  Updating system and xbps package manager..\e[0m"; sleep 3
sudo xbps-install -Suy
sudo xbps-install -uy xbps
sudo xbps-install -Suy

echo -e "\e[1;32m  Minimal GNOME DE installation..\e[0m"; sleep 3
sudo xbps-install -y intel-ucode NetworkManager xorg-minimal dbus elogind mesa-dri intel-video-accel mesa-intel-dri mesa-vulkan-intel xdg-user-dirs xdg-utils gnome-core eog gnome-tweaks alacritty pipewire wireplumber rtkit bluez gvfs ntfs-3g

#for plasma#
# kde5 dolphin konsole; sudo ln -s /etc/sv/sddm /var/service

#for dwm# xorg-minimal dbus elogind mesa-dri xdg-user-dirs pipewire
# base-devel dejavu-fonts-ttf libX11-devel libXft-devel libXinerama-devel fontconfig-devel freetype-devel
# xrandr picom xwallpaper thunar git

# Install VM drivers [MORE TEST NEEDED]
#sudo xbps-install -y xf86-video-qxl

# Set up wireplumber
echo "\e[1;32m> Setting up wireplumber session manager..e[0m"; sleep 3
if command -v pipewire >/dev/null 2>&1 && command -v wireplumber >/dev/null 2>&1; then
	[ ! -d /etc/pipewire/ ] && sudo mkdir -p /etc/pipewire/
	sudo cp /usr/share/pipewire/pipewire.conf /etc/pipewire/
	sudo sed -i '/path.*=.*pipewire-media-session/s/{/#{/' /etc/pipewire/pipewire.conf
	[ ! -d /etc/pipewire/pipewire.conf.d/ ] && sudo mkdir -p /etc/pipewire/pipewire.conf.d/
	echo 'context.exec = [ { path = "/usr/bin/wireplumber" args = "" } ]' | sudo tee /etc/pipewire/pipewire.conf.d/10-wireplumber.conf
else
	echo "\e[1;31m ! ERROR: pipewire and/or wireplumber is not installed!"; sleep 3
fi
sudo cp -v /usr/share/applications/pipewire-pulse.desktop /etc/xdg/autostart/
sudo cp -v /usr/share/applications/pipewire.desktop /etc/xdg/autostart/

# Services
echo -e "\e[1;32m  Disabling services: wpa_supplicant, dhcpcd, sshd..\e[0m"; sleep 3
sudo rm -v /var/service/wpa_supplicant
sudo rm -v /var/service/dhcpcd
sudo rm -v /var/service/sshd
echo -e "\e[1;32m  Enabling services: dbus, NetworkManager, gdm..\e[0m"; sleep 3
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/NetworkManager /var/service/
sudo ln -s /etc/sv/gdm /var/service

echo -e " \e[1;32m------------- DONE! -------------\e[0m "; sleep 3
echo -e "     \e[32mGDM will launch shortly.\e[0m"
