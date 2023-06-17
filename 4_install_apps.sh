#!/bin/bash
#######################################################################################
# Author: 	imatsatsos                                                                #
# Description:	This script install's my preferred applications in an interactive way #
#######################################################################################
# alacritty       > terminal
# geany           > text editor
# htop            > sys monitor
# neovim          > term text editor
# xclip           > Needed for neovim clipboard
# mpv             > media player
# yt-dlp          > download videos from internet
# ffmpeg          > the world runs on this
# easyeffects     > EQ for audio devices
# lutris          > run windows software via wine
# git             > you know, for online git repos
# intel-undervolt > undervolt intel CPUs
# intel-gpu-tools > mainly for itop (intel gpu monitor)
# nvtop           > monitor for nvidia intel amd gpus
# MangoHud        > MSI-afterburner like ingame OSD

PKGS_REPOS="void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree"
PKGS_STEAM="steam libgcc-32bit libstdc++-32bit libdrm-32bit libglvnd-32bit mesa-dri-32bit"
PKGS_STEAM_NVIDIA="nvidia nvidia-vaapi-driver nvidia-libs-32bit"

PKGS_GUI="alacritty geany mpv easyeffects rofi Kooha"
PKGS_CLI="htop ncdu neovim xclip btop ranger nvtop intel-gpu-tools"
PKGS_UTILS="git yt-dlp gcc tree ffmpeg intel-undervolt"
PKGS_3D="MangoHud lutris"
PKGS_SUM="$PKGS_GUI $PKGS_CLI $PKGS_UTILS $PKGS_3D"

FLATPAKS="com.anydesk.Anydesk \
com.brave.Browser \
com.github.tchx84.Flatseal \
com.spotify.Client \
fr.handbrake.ghb \
net.cozic.joplin_desktop \
org.qbittorrent.qBittorrent \
org.signal.Signal"

yellow() {
    title=" $1 "
    echo -e "\e[1;33m$title\e[0m"
}

green(){
	title=" $1 "
	echo -e "\e[1;32m$title\e[0m"
}

red(){
    title=" $1 "
    echo -e "\e[1;31m$title\e[0m"
}
 
menu() {
	yellow "Your Options are:"
	yellow " 1: Install Steam"
	yellow " 2: Install Flatpak"
	yellow " 3: Install Virt-manager"
	yellow " 4: Install a collection of apps"
	yellow " 5: Install a collection of flatpaks"
	yellow " 0: Exit"
	read -p "Enter a number: " choice
}

install_steam() {
	yellow "Do you want to: Install Steam?    [y/N]"
	read -r dm
	if [[ "$dm" == [Y/y] ]]; then
		yellow "Will you use an Nvidia GPU for Steam?    [y/N]"
		read -r dm2
		sudo xbps-install -Sy $PKGS_REPOS
		if [[ "$dm2" == [Y/y] ]]; then
			sudo xbps-install -Sy $PKGS_STEAM $PKGS_STEAM_NVIDIA
		else
			sudo xbps-install -Sy $PKGS_STEAM
		fi
		green "Steam installed!\n"
	fi
}

setup_flatpak() {
	yellow "Do you want to: Setup Flatpak?    [y/N]"
	read -r dm
	if [[ "$dm" == [Y/y] ]]; then
		sudo xbps-install -Sy flatpak; sleep 0.5
		if command -v flatpak >/dev/null 2>&1; then
			flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; sleep 0.5
			flatpak update --appstream
			green "Flatpak installed!\n"
            install_flatpaks
		else
			red "! ERROR: package flatpak is not installed.."
		fi
	fi
}

install_flatpaks() {
    yellow "Do you want to: Install a collection of flatpaks?    [y/N]"
	yellow "FLATPAKS: $FLATPAKS"
    read -r dm
	if [[ "$dm" == [Y/y] ]]; then
        if command -v flatpak >/dev/null 2>&1; then
            if [[ $(flatpak remotes | grep -c flathub) -eq 0 ]]; then
			    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; sleep 0.5
            fi
            for fp in $FLATPAKS;
            do
                flatpak install -y flathub $fp
            done
        else
            red "Setup Flatpak first!"
        fi
    fi
}

install_pkgs() {
	yellow "Do you want to: Install Package Collection?   [y/N]"
	yellow "PKGS: $PKGS_SUM"
	read -r dm
	if [[ "$dm" == [Y/y] ]]; then
		sudo xbps-install -Sy $PKGS_SUM
		green "Collection installed!\n"
	fi
}

install_virtmanager() {
	yellow "Do you want to: Install KVM (virt-manager)?   [y/N]"
	read -r dm
	if [[ "$dm" == [Y/y] ]]; then
		sudo xbps-install -Sy libvirtd virt-manager qemu
		sudo ln -s /etc/sv/libvirtd/ /var/service/
		sudo ln -s /etc/sv/virtlogd/ /var/service/
		sudo usermod -a -G libvirt $(whoami)
		green "Virt-manager installed!\n"
	fi
}

# RUN
yellow "Welcome! This script will help you get your apps installed faf."
while true; do
	menu
	case $choice in
		1)
			install_steam
		;;
		2)
			setup_flatpak
		;;
		3)
			install_virtmanager
		;;
		4)
			install_pkgs
		;;
        5)
            install_flatpaks
        ;;
		0)
			green "Bye bye!"
			exit 0
		;;
		*)
			yellow "Not a valid option."
		;;
	esac
done
