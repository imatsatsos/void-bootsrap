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
	yellow " 6: Setup bluetooth"
	yellow " 7: Setup logs"
	yellow " 8: Setup NIX package manager"
	yellow " 0: Exit"
	read -p "Enter a number: " choice
}

command_exists () {
	command -v "$1" >/dev/null 2>&1;
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

		## make wireplumber autostart from pipewire
		# MANUAL method
		#echo 'context.exec = [ { path = "/usr/bin/wireplumber" args = "" } ]' | sudo tee /etc/pipewire/pipewire.conf.d/10-wireplumber.conf
		# VOID-DOCS method
		[ -f /etc/pipewire/pipewire.conf.d/10-wireplumber.conf ] && sudo rm -f /etc/pipewire/pipewire.conf.d/10-wireplumber.conf
		[ -f /etc/pipewire/pipewire.conf.d/20-pipewire-pulse.conf ] && sudo rm -f /etc/pipewire/pipewire.conf.d/20-pipewire-pulse.conf
		sudo ln -s /usr/share/examples/wireplumber/10-wireplumber.conf /etc/pipewire/pipewire.conf.d/
		## make pipewire-pulse autostart from pipewire
		sudo ln -s /usr/share/examples/pipewire/20-pipewire-pulse.conf /etc/pipewire/pipewire.conf.d/
		# create autostart .desktop files
		sudo cp -f /usr/share/applications/pipewire-pulse.desktop /etc/xdg/autostart/
		sudo cp -f /usr/share/applications/pipewire.desktop /etc/xdg/autostart/
		green "Audio is setup and will autostart for DEs!\n"
		green "For WMs: make sure to run pipewire in your autostart.\n"
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
		[ ! -d /home/"$USER"/.local/bin/ ] && mkdir -p /home/"$USER"/.local/bin/
		cp -f ./envycontrol/envycontrol.py /home/"$USER"/.local/bin/
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
		mkdir -p "$HOME"/Gitrepos
		cd "$HOME"/Gitrepos
		git clone --depth 1 https://github.com/void-linux/void-packages.git
		[ ! -d ./void-packages/ ] && red "! git clone failed" && return
		"$HOME"/Gitrepos/void-packages/xbps-src binary-bootstrap
		sudo xbps-install -Sy xtools
		cd -
		yellow "Usage: ./xbps-src pkg 'name' to build from a template"
		yellow "       xi 'name' to install a built pkg (xi from xtools)"
		green "Done. \n"
	fi
}

setup_bluetooth() {
	yellow "Do you want to setup Bluetooth?  [y/N]"
	read -r dm
	if [[ "$dm" == [Y/y] ]]; then

		yellow "Installing bluetooth and libspa-bluetooth"
		sleep 2
		sudo xbps-install -Sy bluez libspa-bluetooth
		sleep 1
		sudo ln -s /etc/sv/bluetoothd /var/service/
		green "Bluetooth installed!"
	fi
}

setup_logs() {
	yellow "Do you want to setup Logs (socklog-void)?  [y/N]"
	read -r dm
	if [[ "$dm" == [Y/y] ]]; then

		yellow "Installing socklog-void"
		sleep 2
		sudo xbps-install -Sy socklog-void
		sleep 1
		sudo ln -s /etc/sv/socklog-unix /var/service/
		sudo ln -s /etc/sv/nanoklogd /var/service
		green "Logs enabled, see them with svlogtail!"
	fi
}

setup_nix() {
	yellow "Do you want to setup the NIX package manager?  [y/N]"
	read -r dm
	if [[ "$dm" == [Y/y] ]]; then

		yellow "Installing nix package manager"
		sleep 2
		sh <(curl -L https://nixos.org/nix/install) --no-daemon
		sleep 1
		green "NIX is now installed! Make sure to check your .bash_profile."
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
		6)
			setup_bluetooth
			;;
		7)
			setup_logs
			;;
		8)
			setup_nix
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
