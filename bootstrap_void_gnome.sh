#!/bin/bash

###############################################################################################
# Author: imatsatsos                                                                          #
# Description: This script setups Void Linux for Intel systems. It provides the user a choice #
#    to install a minimal GNOME, PLASMA or SUCKLESS (DWM) setup, enables basic services and   #
#    finally provides to install drivers in case the system will be used inside a VM.         #
###############################################################################################

###  Description of all installed pkgs  #######################################################
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
###############################################################################################

COMMON="intel-ucode xorg-minimal dbus elogind xdg-user-dirs xdg-utils pipewire wireplumber rtkit bluez gvfs ntfs-3g"
VGA="mesa-dri intel-video-accel mesa-intel-dri mesa-vulkan-intel"
PKGS="$COMMON $VGA"

echo -e "\e[1;32m Is this a VM?  [Y/N]"
read -r flag_vm

echo -e "\e[1;32m Choose a variant:"
echo -e " Type 1 for GNOME, 2 for PLASMA, 3 for DWM.  [1/2/3]"
read -r variant


echo -e "\e[1;32m  This will take some time, go grab a coffee!\e[0m"; sleep 3
echo -e "\e[1;32m  Initial mirror sync, xmirror install, enabling void-repo-nonfree..\e[0m"; sleep 3
sudo xbps-install -Sy xmirror void-repo-nonfree
sudo xmirror --set https://repo-de.voidlinux.org/


echo -e "\e[1;32m  Updating system and xbps package manager..\e[0m"; sleep 3
sudo xbps-install -Suy
sudo xbps-install -uy xbps
sudo xbps-install -Suy


# Install VM drivers [MORE TEST NEEDED]
if [[ "$flag_vm" == [Y/y] ]]; then
	VGA="mesa-dri xf86-video-qxl"
	PKGS="$COMMON $VGA"
fi


case $variant in
	# 1: GNOME
	1)
		PKGS="$PKGS NetworkManager gnome-core eog gnome-tweaks alacritty"
		DM="gdm"
		echo -e "\e[1;32m  Minimal GNOME DE installation..\e[0m"; sleep 3
		sudo xbps-install -y $PKGS
	;;
	
	# 2: PLASMA
	2)
		PKGS="$PKGS kde5 dolphin konsole"
		DM="sddm"
		echo -e "\e[1;32m  Minimal PLASMA DE installation..\e[0m"; sleep 3
		sudo xbps-install -y $PKGS
	;;
	
	# 3: DWM (suckless)
	3)
		echo -e "\e[1;32m Suckless DWM dependencies installation..\e[0m"; sleep 3
		PKGS="$PKGS base-devel dejavu-fonts-ttf libX11-devel libXft-devel libXinerama-devel fontconfig-devel freetype-devel"
		## for dwm 
		# xrandr picom xwallpaper thunar git
		sudo xbps-install -y $PKGS
		# git clone <dwm st etc..>
		# cd <repodir>
		# sudo make clean install
		# setup .xinitrc
		# startx
	;;
	
	*)
		echo -e "\e[1;31mInvalid variant: please enter 1, 2, or 3.\e[0m"
		exit 1
	;;
esac	


# Set up wireplumber
echo -e "\e[1;32m> Setting up wireplumber session manager..\e[0m"; sleep 3
if command -v pipewire >/dev/null 2>&1 && command -v wireplumber >/dev/null 2>&1; then
	[ ! -d /etc/pipewire/ ] && sudo mkdir -p /etc/pipewire/
	sudo cp /usr/share/pipewire/pipewire.conf /etc/pipewire/pipewire.conf
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
echo -e "\e[1;32m  Enabling services: dbus, NetworkManager..\e[0m"; sleep 3
sudo ln -s /etc/sv/dbus /var/service/
sudo ln -s /etc/sv/NetworkManager /var/service/


echo -e "\e[1;32m------------- DONE! -------------\e[0m"; sleep 3
if [["$variant" -eq 3 ]]; then
	echo -e "\e[32mYou use suckless, you know how to proceed. ;)\e[0m"
else
	sudo ln -s "/etc/sv/$DM" /var/service
	echo -e "    \e[1;32m$DM will start shortly.\e[0m"
fi
