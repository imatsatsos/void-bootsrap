#!/bin/bash
# This scripts setups various system components on a Void Linux installation
# These currently include:
# AUDIO: pipewire with wireplumber server and alsa-utils
# ACPI: setup acpid and elogind to not interfere with each other

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
	yellow "Welcome! This script will setup various system components on a Void Linux installation."
	yellow "Your Options are:"
	yellow " 1: Setup Audio (pipewire, wireplumber, alsa-utils)"
	yellow " 2: Setup acpi and elogin"
	yellow " 3: Install Virt-manager"
	yellow " 4: Install a collection of apps"
	yellow " 0: Exit"
	read -p "Enter a number: " choice
}

command_exists () {
    command -v $1 >/dev/null 2>&1;
}


setup_audio() {
	yellow "Do you want to setup Audio (pipewire, wireplumber, alsa-utils)?  [Y/N]"
	read -r dm1
	if [[ "$dm1" == [Y/y] ]]; then
		
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
		sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
		# create autostart .desktop files
		sudo cp -v /usr/share/applications/pipewire-pulse.desktop /etc/xdg/autostart/
		sudo cp -v /usr/share/applications/pipewire.desktop /etc/xdg/autostart/
		green "Audio is setup!\n"
	fi
}


setup_acpid_elogind() {
	yellow "Do you want to setup ACPID, ELOGIND?  [Y/N]"
	read -r dm2
	if [[ "$dm2" == [Y/y] ]]; then
		
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
		#sudo cp -f ./handler.sh /etc/acpi/handler.sh
		
		# enable acpid service if it's not already linked
		[ ! -d /var/service/acpid ] && sudo ln -s /etc/acpid /var/service/
		green "acpid, elogind are setup!\n"
	fi
}


# RUN
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
			#install_virtmanager
		;;
		4)
			#install_collection
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
