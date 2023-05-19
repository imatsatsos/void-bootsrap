#!/bin/bash

###############################################################################################
# Author: 	imatsatsos                                                                        #
# Description:	This script install's my preferred applications in an interactive way         #
###############################################################################################


box() {
    title=" $1 "
    echo -e "\e[1;31m$title\e[0m"
}
boxg(){
	title=" $1 "
	echo -e "\e[1;32m$title\e[0m"
 }
 
menu() {
	box "Welcome! This script will help you get your apps installed faf."
	box "Your Options are:"
	box " 1: Install Steam"
	box " 2: Install Flatpak"
	box " 3: Install Virt-manager"
	box " 4: Install a collection of apps"
	box " 0: Exit"
	read -p "Enter a number: " choice
}

install_steam() {
	box "Do you want to: Install Steam?  [Y/N]"
	read -r dm1
	if [[ "$dm1" == [Y/y] ]]; then
		sudo xbps-install -Sy void-repo-nonfree void-repo-multilib{,-nonfree}
		sudo xbps-install -Sy steam libgcc-32bit libstdc++-32bit libdrm-32bit libglvnd-32bit mesa-dri-32bit
		box "Will you use an Nvidia GPU for Steam?  [Y/N]"
		read -r dm2
		if [[ "$dm2" == [Y/y] ]]; then
			sudo xbps-install -y nvidia-libs-32bit
		fi
		boxg "Steam installed!"; echo ""
	fi
}

install_flatpak() {
	box "Do you want to: Install Flatpak?  [Y/N]"
	read -r dm3
	if [[ "$dm3" == [Y/y] ]]; then
		sudo xbps-install -Sy flatpak; sleep 0.5
		if command -v flatpak >/dev/null 2>&1; then
			flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; sleep 0.5
			flatpak update --appstream
			boxg "Flatpak installed!"; echo ""
		else
			box "! ERROR: Something went wrong .."
		fi
	## TODO: menu for some of my flatpaks
	fi
}

install_collection() {
	box "Do you want to: Install Collection?   [Y/N]"
	box "(alacritty, geany, htop, neovim, mpv, yt-dlp, easyeffects, lutris, fzf, curl"
	box " git, xmirror, xrandr, xinput, intel-undervolt, intel-gpu-tools, glxinfo, libva-utils)"
	read -r dm4
	if [[ "$dm4" == [Y/y] ]]; then
		sudo xbps-install -Sy alacritty geany htop neovim mpv yt-dlp ffmpeg easyeffects lutris fzf
		sudo xbps-install -y curl git xmirror xrandr xinput intel-undervolt intel-gpu-tools nvtop MangoHud glxinfo libva-utils
		boxg "Collection installed!"; echo ""
	fi
}
# alacritty > terminal
# geany > text editor
# htop > sys monitor
# neovim > term text editor
# mpv > media player
# yt-dlp > download videos from internet
# ffmpeg > the world runs on this
# easyeffects > EQ for audio devices
# lutris > run windows software via wine
# fzf > fuzzy search
# curl > to download stuff from cli
# git > you know, for online git repos
# xmirror > void app to change xbps mirrors
# xrandr > to change screen resolution and more on xorg
# xinput > used to fix my touchpad scroll speed
# intel-undervolt > undervolt intel CPUs
# intel-gpu-tools > mainly for itop (intel gpu monitor)
# nvtop           > monitor for nvidia intel amd gpus
# glxinfo > cli util to verify gpu drivers
# libva-utils > cli util to verify vaapi support
# MangoHud > MSI-afterburner like ingame OSD

install_virtmanager() {
	box "Do you want to: Install KVM (virt-manager)?  [Y/N]"
	read -r dm4
	if [[ "$dm5" == [Y/y] ]]; then
		sudo xbps-install -Sy libvirtd virt-manager qemu
		sudo ln -s /etc/sv/libvirtd/ /var/service/
		sudo ln -s /etc/sv/virtlogd/ /var/service/
		sudo usermod -a -G libvirt $(whoami)
		boxg "Virt-manager installed!"; echo ""
	fi
}

# RUN
while true; do
	menu
	case $choice in
		1)
			install_steam
		;;
		2)
			install_flatpak
		;;
		3)
			install_virtmanager
		;;
		4)
			install_collection
		;;
		0)
			boxg "Bye bye!"
			exit 0
		;;
		*)
			echo ""
		;;
	esac
done
