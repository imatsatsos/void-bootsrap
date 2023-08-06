#!/bin/bash
###############################################################################################
# Author: imatsatsos                                                                          #
# Description: This script setups Void Linux for Intel systems. It provides the user a choice #
#  to install a minimal GNOME, PLASMA, i3, or SUCKLESS (DWM) setup and enables basic services #
###############################################################################################

###  Description of packages  #################################################################
# void-repo-nonfree     > required for intel CPU microcode
# xmirror               > void util to set xbps mirror
# ------- COMMON -------
# intel-ucode 		    > microcode update for intel CPUs
# dbus 				    > needed for apps to talk to the desktop bus
# NetworkManager 	    > internet conn  manager, it just works for wifi
# elogind               > seat management
# power-profiles-daemon > manage INTEL CPU power profile
# xdg-user-dirs 	    > XDG support for /downloads, /documents, etc..
# xdg-utils 		    > basic XDG support (xdg-open, etc..)
# pipewire 			    > new-era audio engine
# wireplumber 		    > new-era audio session manager
# alsa-utils            > alsamixer mainly
# rtkit 			    > pipewire optional dependency, sets realtime priority
# bluez 			    > bluetooth support
# gvfs 				    > mounting drives and trash for gnome
# -------- XORG --------
# xorg-minimal 		    > minimal xorg setup
# xrandr                > to change screen resolution and more on xorg
# xrdb                  > merge .Xresources to xorg
# xinput                > xset, touchpad scroll speed
# xprop                 > i3 wm
# setxkbmap             > change keyboard layout
# -------- VGA ---------
# mesa-dri 			    > mesa driver for opengl hw accel
# intel-video-accel     > intel gpu driver + hw accel codecs
# mesa-intel-dri 	    > mesa support for intel gpu
# mesa-vulkan-intel     > vulkan intel driver
# nvidia                > nvidia driver
# ------- GNOME --------
# gnome-core 		    > minimal gnome DE
# eog 				    > eye of gnome, image viewer
# gnome-tweaks 		    > gnome tweaks app
# dconf-editor          > edit hidden gnome settings, like volume step 
# alacritty             > terminal
# -------- KDE ---------
# kde5                  > minimal kde plasma DE
# dolphin               > kde file explorer
# konsole               > kde terminal
# --------- i3 ---------
# i3
# i3blocks
# i3lock
# xst
# dejavu-fonts-ttf
# pcmanfm
# feh
# NetworkManager
# lxappearance
# dunst
# gnome-keyring
# dmenu
# xwallpaper
# polkit-gnome
# nsxiv
###############################################################################################

COMMON="intel-ucode NetworkManager dbus elogind power-profiles-daemon xdg-user-dirs xdg-utils pipewire wireplumber alsa-utils rtkit gvfs bluez libspa-bluetooth"
X11="xorg-minimal xrandr xrdb xinput xclip xprop setxkbmap xsetroot xdotool"
VGA="mesa-dri intel-video-accel mesa-intel-dri mesa-vulkan-intel"
PKGS_BASE="$X11 $COMMON $VGA"

PKGS_GNOME="gnome-core eog file-roller gnome-tweaks dconf-editor alacritty"
PKGS_PLASMA="kde5 dolphin konsole"
PKGS_WM="gnome-keyring polkit-gnome upower pcmanfm sxhkd mpv dmenu rofi lxappearance dunst xwallpaper dejavu-fonts-ttf picom nsxiv maim playerctl"
PKGS_DWM="base-devel libX11-devel libXft-devel libXinerama-devel"
PKGS_I3="i3 alacritty i3status i3blocks i3lock"
PKGS_SWAY="sway swaylock swayidle i3blocks"

echo -e "\e[1;32m Is this a VM?  [y/N]"
read flag_vm

# Fewer pkgs and VM drivers [MORE TEST NEEDED]
if [[ "$flag_vm" == [Y/y] ]]; then
	#VGA="mesa-dri"
	VGA=" "
	COMMON="NetworkManager dbus elogind xdg-user-dirs xdg-utils pipewire wireplumber alsa-utils rtkit gvfs"
	PKGS_BASE="$X11 $COMMON $VGA"
fi

if [[ "$flag_vm" != [Y/y] ]]; then
	echo -e "\e[1;32m Do you want to install NVIDIA drivers?  [y/N]"
	read flag_nvidia
	# Install NVIDIA drivers [MORE TEST NEEDED]
	if [[ "$flag_nvidia" == [Y/y] ]]; then
		VGA="$VGA nvidia nvidia-vaapi-driver"
		PKGS_BASE="$X11 $COMMON $VGA"
	fi
fi

echo -e "\e[1;32m Choose a variant:"
echo -e "\e[1;32m 1: Gnome"
echo -e "\e[1;32m 2: Plasma"
echo -e "\e[1;32m 3: dwm"
echo -e "\e[1;32m 4: i3"
echo -e "\e[1;32m 5: Sway"
read -p "number: " variant


echo -e "\e[1;32m  This will take some time, go grab a coffee!\e[0m"; sleep 2
echo -e "\e[1;32m  Initial mirror sync, xmirror install, enabling void-repo-nonfree..\e[0m";
sudo xbps-install -Sy xmirror void-repo-nonfree
sudo xmirror --set https://repo-de.voidlinux.org/


echo -e "\e[1;32m  Updating system and xbps package manager..\e[0m"; sleep 3
sudo xbps-install -Suy
sudo xbps-install -uy xbps
sudo xbps-install -Suy


case $variant in
	# 1: GNOME
	1)
	PKGS="$PKGS_BASE $PKGS_GNOME"
	DM="gdm"
	echo -e "\e[1;32m  Minimal GNOME DE installation..\e[0m"; sleep 3
	sudo xbps-install -y $PKGS
	;;

	# 2: PLASMA
	2)
	PKGS="$PKGS_BASE $PKGS_PLASMA"
	DM="sddm"
	echo -e "\e[1;32m  Minimal PLASMA DE installation..\e[0m"; sleep 3
	sudo xbps-install -y $PKGS
	;;

	# 3: DWM (suckless)
	3)
	echo -e "\e[1;32m Suckless DWM dependencies installation..\e[0m"; sleep 3
	PKGS="$PKGS_BASE $PKGS_WM $PKGS_DWM"
	sudo xbps-install -y $PKGS
	git clone https://github.com/imatsatsos/suckless.git
	# install: dwmblocks, st
	# git clone <dwm st etc..>
	# cd <repodir>
	# sudo make clean install
	;;

    # 4: i3
    4)
    echo -e "\e[1;32m Minimal i3 installation..\e[0m"; sleep 3
    PKGS="$PKGS_BASE $PKGS_WM $PKGS_I3"
    sudo xbps-install -y $PKGS
    ;;

    # 5: Sway
    5)
    echo -e "\e[1;32m Minimal Sway installation..\e[0m"; sleep 3
    PKGS="$COMMON $VGA $PKGS_WM $PKGS_SWAY"
    sudo xbps-install -y $PKGS
    ;;
*)
	echo -e "\e[1;31mInvalid variant.\e[0m"
	exit 1
	;;
esac	


echo -e "\e[1;33m> Almost done now. Are you here?.. (Press any key)\e[0m"; read -r blabla

# Set up pipewire & wireplumber
echo -e "\e[1;32m> Setting up audio (pipewire with wireplumber)..\e[0m"; sleep 2 
if command -v pipewire >/dev/null 2>&1 && command -v wireplumber >/dev/null 2>&1; then
	[ ! -d /etc/pipewire/ ] && sudo mkdir -p /etc/pipewire/
	[ ! -d /etc/pipewire/pipewire.conf.d/ ] && sudo mkdir -p /etc/pipewire/pipewire.conf.d/
	## make wireplumbeer autostart from pipewire
	sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
	## make pipewire-pulse autostart from pipewire
	sudo ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/
	#sudo cp -v /usr/share/applications/pipewire-pulse.desktop /etc/xdg/autostart/
	sudo cp -v /usr/share/applications/pipewire.desktop /etc/xdg/autostart/
else
	echo "\e[1;31m ! ERROR: pipewire and/or wireplumber is not installed!"; sleep 2
fi

# Services
if [[ "$flag_vm" == [Y/y] ]]; then
	echo -e "\e[1;32m  Disabling services: wpa_supplicant, sshd..\e[0m"; sleep 2
	sudo rm -v /var/service/{wpa_supplicant,sshd}
else
	echo -e "\e[1;32m  Disabling services: wpa_supplicant, dhcpcd, sshd..\e[0m"; sleep 2
	sudo rm -v /var/service/{wpa_supplicant,dhcpcd,sshd}
fi
echo -e "\e[1;32m  Enabling services: dbus, NetworkManager, bluetoothd, power-profiles-manager..\e[0m"; sleep 2
sudo ln -sv /etc/sv/{dbus,NetworkManager,bluetoothd,power-profiles-manager} /var/service/

# create home directories
xdg-user-dirs-update

echo -e "\e[1;32m------------- DONE! -------------\e[0m"; sleep 2
if [[ $variant -eq 3 ]]; then
	cp ./resources/.xinitrc /home/"$USER"/
	echo -e "\e[1;32mYou use suckless, you know how to proceed. ;)\e[0m"
	echo -e "   \e[1;32m an example .xinitrc is created, edit it and run startx!\e[0m"
elif [[ $variant -eq 4 ]]; then
	cp ./resources/.xinitrc /home/"$USER"/
	echo -e "   \e[1;32m an example .xinitrc is created, edit it and run startx!\e[0m"
else
	sudo ln -sv "/etc/sv/$DM" /var/service
	echo -e "   \e[1;32m$DM will start shortly.\e[0m"
fi
echo -e "\e[1;32mA restart is highly recommended!\e[0m"; sleep 2
