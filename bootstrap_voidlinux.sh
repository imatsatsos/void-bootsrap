#!/bin/bash

###############################################################################################
# Author: imatsatsos                                                                          #
# Description: This script setups Void Linux for Intel systems. It provides the user a choice #
#    to install a minimal GNOME, PLASMA, i3, or SUCKLESS (DWM) setup, enables basic services and   #
#    finally provides to install drivers in case the system will be used inside a VM.         #
###############################################################################################

###  Description of all installed pkgs  #######################################################
# xmirror 			> void utility to set xbps mirror, I set it to tier-1 Germany
# void-repo-nonfree > required for intel CPU microcode
# intel-ucode 		> microcode update for intel CPUs
# NetworkManager 	> internet conn  manager, it just works for wifi
# xorg-minimal 		> minimal xorg setup
# dbus 				> needed for apps to talk to the desktop bus
# mesa-dri 			> mesa driver for opengl hw accel
# intel-video-accel > intel gpu driver + hw accel codecs
# mesa-intel-dri 	> mesa support for intel gpu
# mesa-vulkan-intel > vulkan intel driver
# nvidia            > nvidia driver
# xdg-utils 		> basic XDG support (xdg-open, etc..)
# xdg-user-dirs 	> XDG support for /downloads, /documents, etc..
# gnome-core 		> minimal gnome DE
# eog 				> eye of gnome, image viewer
# gnome-tweaks 		> gnome tweaks app
# dconf-editor      > edit hidden gnome settings, like volume step 
# alacritty         > terminal
# kde5              > minimal kde plasma DE
# dolphin           > kde file explorer
# konsole           > kde terminal
# pipewire 			> new-era audio engine
# wireplumber 		> new-era audio session manager
# rtkit 			> pipewire optional dependency, sets realtime priority
# bluez 			> bluetooth support
# gvfs 				> mounting drives and trash for gnome
###############################################################################################

COMMON="intel-ucode dbus elogind power-profiles-daemon xdg-user-dirs xdg-utils pipewire wireplumber alsa-utils rtkit bluez gvfs"
XORG="xorg-minimal xrandr xrdb xinput setxkbmap"
VGA="mesa-dri intel-video-accel mesa-intel-dri mesa-vulkan-intel"
PKGS="$XORG $COMMON $VGA"

PKGS_GNOME="gnome-core NetworkManager eog gnome-tweaks dconf-editor alacritty"
PKGS_PLASMA="kde5 dolphin konsole"
PKGS_DWM="base-devel xst pcmanfm dejavu-fonts-ttf libX11-devel libXft-devel libXinerama-devel fontconfig-devel freetype-devel"
PKGS_I3="i3 i3blocks i3lock xst dejavu-fonts-ttf pcmanfm NetworkManager lxappearance dunst gnome-keyring dmenu xwallpaper sysstat polkit-gnome gettext"

echo -e "\e[1;32m Is this a VM?  [Y/N]"
read flag_vm
# Fewer pkgs and VM drivers [MORE TEST NEEDED]
if [[ "$flag_vm" == [Y/y] ]]; then
	VGA="mesa-dri xf86-video-qxl"
	COMMON="dbus elogind xdg-user-dirs xdg-utils pipewire wireplumber alsa-utils rtkit gvfs"
	PKGS="$XORG $COMMON $VGA"
fi

if [[ "$flag_vm" != [Y/y] ]]; then
	echo -e "\e[1;32m Do you want to install NVIDIA drivers?  [Y/N]"
	read flag_nvidia
	# Install NVIDIA drivers [MORE TEST NEEDED]
	if [[ "$flag_nvidia" == [Y/y] ]]; then
		VGA="$VGA nvidia nvidia-vaapi-driver"
		PKGS="$XORG $COMMON $VGA"
	fi
fi

echo -e "\e[1;32m Choose a variant:"
echo -e "\e[1;32m 1: Gnome"
echo -e "\e[1;32m 2: Plasma"
echo -e "\e[1;32m 3: dwm"
echo -e "\e[1;32m 4: i3"
read -p "number: " variant


echo -e "\e[1;32m  This will take some time, go grab a coffee!\e[0m"; sleep 3
echo -e "\e[1;32m  Initial mirror sync, xmirror install, enabling void-repo-nonfree..\e[0m"; sleep 3
sudo xbps-install -Sy xmirror void-repo-nonfree
sudo xmirror --set https://repo-de.voidlinux.org/


echo -e "\e[1;32m  Updating system and xbps package manager..\e[0m"; sleep 3
sudo xbps-install -Suy
sudo xbps-install -uy xbps
sudo xbps-install -Suy


case $variant in
	# 1: GNOME
	1)
		PKGS="$PKGS $PKGS_GNOME"
		DM="gdm"
		echo -e "\e[1;32m  Minimal GNOME DE installation..\e[0m"; sleep 3
		sudo xbps-install -y $PKGS
	;;
	
	# 2: PLASMA
	2)
		PKGS="$PKGS $PKGS_PLASMA"
		DM="sddm"
		echo -e "\e[1;32m  Minimal PLASMA DE installation..\e[0m"; sleep 3
		sudo xbps-install -y $PKGS
	;;
	
	# 3: DWM (suckless)
	3)
		echo -e "\e[1;32m Suckless DWM dependencies installation..\e[0m"; sleep 3
		PKGS="$PKGS $PKGS_DWM"
		## for dwm 
		# xrandr picom xwallpaper thunar git
		sudo xbps-install -y $PKGS
		# git clone <dwm st etc..>
		# cd <repodir>
		# sudo make clean install
		# setup .xinitrc
		# startx
	;;
    
    # 4: i3
    4)
        echo -e "\e[1;32m Minimal i3 installation..\e[0m"; sleep 3
        PKGS="$PKGS $PKGS_I3"
        sudo xbps-install -y $PKGS
    ;;
	
    *)
		echo -e "\e[1;31mInvalid variant.\e[0m"
		exit 1
	;;
esac	


echo -e "\e[1;31m> Almost done now. Are you here?.. (press any key)\e[0m"; read -r blabla

# Set up wireplumber
echo -e "\e[1;32m> Setting up wireplumber session manager..\e[0m"; sleep 3
if command -v pipewire >/dev/null 2>&1 && command -v wireplumber >/dev/null 2>&1; then
	[ ! -d /etc/pipewire/ ] && sudo mkdir -p /etc/pipewire/
	[ ! -d /etc/pipewire/pipewire.conf.d/ ] && sudo mkdir -p /etc/pipewire/pipewire.conf.d/
	sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
	sudo cp -v /usr/share/applications/pipewire-pulse.desktop /etc/xdg/autostart/
	sudo cp -v /usr/share/applications/pipewire.desktop /etc/xdg/autostart/
else
	echo "\e[1;31m ! ERROR: pipewire and/or wireplumber is not installed!"; sleep 3
fi

# Services
if [[ "$flag_vm" == [Y/y] ]]; then
	echo -e "\e[1;32m  Disabling services: wpa_supplicant, sshd..\e[0m"; sleep 3
	sudo rm -v /var/service/{wpa_supplicant,sshd}
else
	echo -e "\e[1;32m  Disabling services: wpa_supplicant, dhcpcd, sshd..\e[0m"; sleep 3
	sudo rm -v /var/service/{wpa_supplicant,dhcpcd,sshd}
fi
echo -e "\e[1;32m  Enabling services: dbus, NetworkManager..\e[0m"; sleep 3
sudo ln -s /etc/sv/{dbus,NetworkManager} /var/service/
if [[ $variant -eq 4 ]]; then
	sudo ln -s /etc/sv/power-profiles-daemon /var/service/
fi

echo -e "\e[1;32m------------- DONE! -------------\e[0m"; sleep 3
if [[ $variant -eq 3 ]]; then
	echo -e "\e[1;32mYou use suckless, you know how to proceed. ;)\e[0m"
elif [[ $variant -eq 4 ]]; then
	cp ./resources/.xinitrc /home/$USER/
	#echo "exec dbus-launch --exit-with-session /usr/bin/i3" > /home/$USER/.xinitrc
	echo -e "   \e[1;32m$.xinitrc for i3 created, run startx!\e[0m"
else
	sudo ln -s "/etc/sv/$DM" /var/service
	echo -e "   \e[1;32m$DM will start shortly.\e[0m"
fi
