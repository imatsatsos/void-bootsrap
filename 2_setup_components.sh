#!/bin/bash
# AUTHOR: imatsatsos
# This script setups various system components on a Void Linux installation
# These currently include:
# AUDIO: pipewire with wireplumber server and alsa-utils
# ACPID: setup acpid to handle acpi events and disable them for elogind to 
#  not interfere with each other. Some extra bling included
# NVIDIA: install drivers for nvidia 
# ENVYCONTROL: utility to toggle integrated and NVIDIA gpu


yellow() {
    title="$1"
    echo -e "\e[1;33m$title\e[0m"
}

green(){
	title="$1"
	echo -e "\e[1;32m$title\e[0m"
}

red(){
    title="$1"
    echo -e "\e[1;31m$title\e[0m"
}


menu() {
	yellow "Your Options are:"
	yellow " 1: Setup Audio (pipewire, wireplumber, alsa-utils)"
	yellow " 2: Setup Acpid and Elogind"
	yellow " 3: Install NVIDIA drivers"
	yellow " 4: Install/update Envycontrol"
	yellow " 5: Setup Void source pkgs"
    yellow " 0: Exit"
	read -p "Enter a number: " choice
}

command_exists () {
    command -v $1 >/dev/null 2>&1;
}


setup_audio() {
	yellow "Do you want to setup Audio (pipewire, wireplumber, alsa-utils)?  [y/N]"
	read -r dm
	if [[ "$dm" == [Y/y] ]]; then
		
		# check to install pipewire, wireplumber, alsa-utils
		if ! command_exists pipewire wireplumber alsa-utils; then
			sudo xbps-install -Sy pipewire wireplumber alsa-utils
		fi
		
		# check to create folders
		[ ! -d /etc/pipewire/ ] && sudo mkdir -p /etc/pipewire/
		[ ! -d /etc/pipewire/pipewire.conf.d/ ] && sudo mkdir -p /etc/pipewire/pipewire.conf.d/
		
		#! NOT NEEDED as of 30 May 2023 ( https://voidlinux.org/news/2023/05/audio-breakage.html )
		# copy pipewire config to disable the default media session
		#sudo cp -f /usr/share/pipewire/pipewire.conf /etc/pipewire/pipewire.conf
		#sudo sed -i '/path.*=.*pipewire-media-session/s/{/#{/' /etc/pipewire/pipewire.conf
		
		# make wireplumber autostart from pipewire
		# another method
		#echo 'context.exec = [ { path = "/usr/bin/wireplumber" args = "" } ]' | sudo tee /etc/pipewire/pipewire.conf.d/10-wireplumber.conf
		# void docs method
		[ -f /etc/pipewire/pipewire.conf.d/10-wireplumber.conf ] && sudo rm -f /etc/pipewire/pipewire.conf.d/10-wireplumber.conf
        sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
		# create autostart .desktop files
		sudo cp -f /usr/share/applications/pipewire-pulse.desktop /etc/xdg/autostart/
		sudo cp -f /usr/share/applications/pipewire.desktop /etc/xdg/autostart/
		green "Audio is setup!\n"
	fi
}


setup_acpid_elogind() {
	yellow "Do you want to setup ACPID and ELOGIND?  [y/N]"
	read -r dm
	if [[ "$dm" == [Y/y] ]]; then
		
		# check to install acpid and elogind
		if ! command_exists acpid loginctl; then
			sudo xbps-install -Sy acpid elogind
		fi
		
		# disabling elogind acpi event handling
		# acpi events will be handled by acpid
		sudo sed -i '/#HandlePowerKey=poweroff/ s/^#\(.*=\).*$/\1ignore/' /etc/elogind/logind.conf
		sudo sed -i '/#HandleSuspendKey=suspend/ s/^#\(.*=\).*$/\1ignore/' /etc/elogind/logind.conf
		sudo sed -i '/#HandleLidSwitch=suspend/ s/^#\(.*=\).*$/\1ignore/' /etc/elogind/logind.conf
		sudo sed -i '/#HandleLidSwitchExternalPower=suspend/ s/^#\(.*=\).*$/\1ignore/' /etc/elogind/logind.conf
		
		# copy new acpid handler.sh
		sudo cp -f ./resources/etc/handler.sh /etc/acpi/handler.sh
		
		# enable acpid service if it's not already linked
		[ ! -d /var/service/acpid ] && sudo ln -s /etc/sv/acpid /var/service/
		green "acpid, elogind are setup!\n"
	fi
}

install_nvidia() {
    yellow "Do you want to install NVIDIA drivers? [y/N]"
    read -r dm
    if [[ "$dm" == [Y/y] ]]; then

        yellow "Installing NVIDIA drivers"
        sleep 2
        sudo xbps-install -Sy void-repo-multilib
        sleep 1
        sudo xbps-install -Sy nvidia nvidia-vaapi-driver nvidia-libs-32bit
        
        green "NVIDIA drivers installed! Good luck :P"
    fi
}

install_envycontrol() {
 	yellow "Do you want to install/update Envycontrol?  [y/N]"
	read -r dm
	if [[ "$dm" == [Y/y] ]]; then

        yellow "Installing envycontrol git to ~/.local/bin/"
        sleep 2
        git clone https://github.com/bayasdev/envycontrol.git
        [ ! -d ./envycontrol/ ] && red "! git clone failed" && return
        [ ! -d /home/$USER/.local/bin/ ] && mkdir -p /home/$USER/.local/bin/
        cp -f ./envycontrol/envycontrol.py /home/$USER/.local/bin/
        rm -rf ./envycontrol/
        green "Done. envycontrol is installed in ~/.local/bin\n"
    fi
}

setup_voidsrcpkgs() {
 	yellow "Do you want to setup Void-source-packages?  [y/N]"
	read -r dm
	if [[ "$dm" == [Y/y] ]]; then

        yellow "Installing to ~/Gitrepos/void-packages"
        sleep 2
        # dependencies
        sudo xbps-install -Sy git curl
        mkdir -p $HOME/Gitrepos
        cd $HOME/Gitrepos
        git clone --depth 1 https://github.com/void-linux/void-packages.git
        [ ! -d ./void-packages/ ] && red "! git clone failed" && return
        $HOME/void-packages/xbps-src binary-bootstrap
        sudo xbps-install -Sy xtools
        cd -
        yellow "Usage: ./xbps-src pkg 'name' to build from a template"
        yellow "       xi 'name' to install a built pkg (xi from xtools)"
        green "Done. \n"
    fi
}
# RUN
yellow "Welcome! This script will setup various system components on a Void Linux installation."
while true; do
	menu
	case $choice in
		1)
			setup_audio
		;;
		2)
			setup_acpid_elogind
		;;
		3)
			install_nvidia
		;;
		4)
			install_envycontrol
        ;;
        5)
            setup_voidsrcpkgs
        ;;
        0)
			green "Bye bye!"
			exit 0
		;;
		*)
			echo "Not a valid option.."
		;;
	esac
done
