#!/bin/bash

###############################################################################################
# Author: 	imatsatsos                                                                        #
# Description:	This script install's the tweaks I use on a Void Linux system                 #
###############################################################################################

# boxes for nice text
boxf() {
    title=" $1 "
    edge=$(echo "$title" | sed 's/./*/g')
    echo "$edge"
    echo -e "\e[1;32m$title\e[0m"
    echo "$edge"
}

boxu() {
    title=" $1 "
    edge=$(echo "$title" | sed 's/./*/g')
    echo "$edge"
    echo -e "\e[1;32m$title\e[0m"
}

box() {
    title=" $1 "
    echo -e "\e[1;32m$title\e[0m"
}

boxd() {
    title=" $1 "
    edge=$(echo "$title" | sed 's/./*/g')
    echo -e "\e[1;32m$title\e[0m"
    echo "$edge"
}

### Check if Script is Run as Root ###
check_root() {
    if [[ "$EUID" = 0 ]]; then
        box "Please rerun this as a regular user!" 2>&1
        sleep 2
        exit 1
    fi
}

opening() {
    boxu  "                   !!!!  IMPORTANT  !!!!                    "
    boxu "   THIS SCRIPT MODIFIES SERVICES, APPLICATION AUTOSTARTS,   "
    box  "   REMOVES APPS, TWEAKS SETTINGS AND APPLIES MY PREFFERED   "
    box  " SETUP TO A VOID LINUX SYSTEM. READ IT BEFORE RUNNING IT.   "
    boxd "            Do you still want to continue? [Y/N]            "
    read -r accept
    if [[ "$accept" == [Y/y] ]];
    then
        box "OK! Lets get started! \n"
    else
        box "That's ok, thanks for checking out this script \n"
        exit
    fi
}

check_deps() {
    if command -v curl &> /dev/null && command -v git &> /dev/null && command -v fc-cache &> /dev/null && command -v unzip &> /dev/null
    then
        box "Dependencies found! \n"
    else
		boxf "Installing dependencies.."
        for pkmgr in xbps-install pacman; do
            type -P "$pkmgr" &> /dev/null || continue
            case $pkmgr in
                xbps-install)
                    sudo xbps-install -Sy curl git fontconfig unzip
                    box "Done \n"
                    ;;
                pacman)
                    sudo pacman -Suy curl git fontconfig unzip
                    ;;
            esac
            return
        done 
    fi
}

### Disable useless services (for a laptop) ###
disable_services() {
    boxf "> Disabling useless services.."
    sleep 2
    [ -d /var/service/wpa_supplicant ] 	&& sudo rm -v /var/service/wpa_supplicant
    [ -d /var/service/dhcpcd ] 			&& sudo rm -v /var/service/dhcpcd
    [ -d /var/service/sshd ] 			&& sudo rm -v /var/service/sshd
    box "Done \n"
}

### Disable autostarts, mainly gnome ###
disable_autostarts() {    
    boxf "> Disabling useless autostarts.."
    sleep 2
    SYS_AUTOSTART="/etc/xdg/autostart/"; USER_AUTOSTART="~/.config/autostart/";
    [ ! -d ${USER_AUTOSTART} ] &&  mkdir -p ${USER_AUTOSTART}
    [ ! -f ${USER_AUTOSTART}/zeitgeist-datahub.desktop ] 						&& cp -v ${SYS_AUTOSTART}/zeitgeist-datahub.desktop 				${USER_AUTOSTART}
    echo "Hidden=true" >> ${USER_AUTOSTART}/zeitgeist-datahub.desktop
    [ ! -f ${USER_AUTOSTART}/org.gnome.SettingsDaemon.Wacom.desktop ] 			&& cp -v ${SYS_AUTOSTART}/org.gnome.SettingsDaemon.Wacom.desktop 	${USER_AUTOSTART}
    echo "Hidden=true" >> ${USER_AUTOSTART}/org.gnome.SettingsDaemon.Wacom.desktop
    [ ! -f ${USER_AUTOSTART}/org.gnome.SettingsDaemon.A11ySettings.desktop ] 	&& cp -v ${SYS_AUTOSTART}/org.gnome.SettingsDaemon.A11ySettings.desktop ${USER_AUTOSTART}
    echo "Hidden=true" >> ${USER_AUTOSTART}/org.gnome.SettingsDaemon.A11ySettings.desktop
    [ ! -f ${USER_AUTOSTART}/org.gnome.Evolution-alarm-notify.desktop ] 		&& cp -v ${SYS_AUTOSTART}/org.gnome.Evolution-alarm-notify.desktop 	${USER_AUTOSTART}
    echo "Hidden=true" >> ${USER_AUTOSTART}/org.gnome.Evolution-alarm-notify.desktop
    #[ ! -f ~/.config/autostart/tracker-miner-fs-3.desktop ] && cp -v /etc/xdg/autostart/tracker-miner-fs-3.desktop ~/.config/autostart/
    #echo "Hidden=true" >> ~/.config/autostart/tracker-miner-fs-3.desktop
    box "Done \n"
}

### Remove useless packages ###
remove_packages() {
    boxf "> Removing useless packages.."
    sleep 2
    sudo cp -v ./resources/99-ignored-pkgs.conf /etc/xbps.d/99-ignored-pkgs.conf
    sudo xbps-remove -Fy linux-firmware-amd linux-firmware-broadcom mobile-broadband-provider-info ipw2200-firmware ipw2100-firmware
    box "Done \n"
}

### Set io-schedulers ###
set_io_schedulers() {
    boxf "> Setting io-schedulers.."
    sleep 2
    [ ! -d /etc/udev/rules.d/ ] && sudo mkdir -p /etc/udev/rules.d/
    sudo cp -v ./resources/60-ioschedulers.rules /etc/udev/rules.d/60-ioschedulers.rules
    box "Done \n"
}

### Set ntfs3 kernel mod for default ntfs mounting
set_ntfs3() {
	boxf "> Setting ntfs3 by default.."
    sleep 2
    [ ! -d /etc/udev/rules.d/ ] && sudo mkdir -p /etc/udev/rules.d/
    sudo cp -v ./resources/ntfs3_default.rules /etc/udev/rules.d/ntfs3_default.rules
    box "Done \n"
}

### Set modprobe blacklist ###
set_modprobe_bl() {
    boxf "> Setting modprobe.."
    sleep 2
    [ ! -d /etc/modprobe.d/ ] && mkdir -p /etc/modprobe.d/
    sudo cp -v ./resources/modprobe.conf /etc/modprobe.d/modprobe.conf
    box "Done \n"
}

### Optimized Intel Graphics with modprobe
set_intel_optim() {
	boxf "> Optimizing Intel Graphics.."
	sleep 2
	[ ! -d /etc/modprobe.d/ ] && mkdir -p /etc/modprobe.d/
	sudo cp -v ./resources/intel-graphics.conf /etc/modprobe.d/intel-graphics.conf
	box "Done \n"
}

### Create intel-undervolt service ###
sv_intel_undervolt() {
    boxf "> Creating intel-undervolt service and setting undervolt conf.."
    sleep 2
    sudo xbps-install -y intel-undervolt
    sudo cp ./resources/intel-undervolt.conf /etc/intel-undervolt.conf
    if [ -d "/etc/sv/intel-undervolt/"  ]; then
		box "! intel-undervolt service already configured \n"
	else
		sudo mkdir -p /etc/sv/intel-undervolt/
		sudo cp -fv ./resources/intel-undervolt/run /etc/sv/intel-undervolt/run
		sudo chmod +x /etc/sv/intel-undervolt/run
		sudo ln -s /etc/sv/intel-undervolt /var/service/
		box "Done \n"
    fi
}

### Gaming tweaks ###
gaming_tweaks() {
    boxf "> Setting vm.max_map_count, Enabling Esync.."
    sleep 1.5
    # vm.max_map_count
    echo "vm.max_map_count=2147483642" | sudo tee -a /etc/sysctl.conf
    # enable Esync
    sleep 1.5
    echo "$(whoami) hard nofile 524288" | sudo tee -a /etc/security/limits.conf
    sleep 1.5
    boxf "> Enabling MangoHud CPU (Intel) Power access.."
    sudo chmod o+r /sys/class/powercap/intel-rapl\:0/energy_uj
    box "Done \n"
}

### Purge old kernels
purge_kernels() {
    boxf "> Purging old kernels.."
    sleep 2
    sudo xbps-remove -y linux5.19 >/dev/null
    sudo vkpurge rm all
    box "Done \n"
}

### Install intel microcode and rebuild initramfs ###
intel_microcode() {
    boxf "> Installing intel-ucode and rebuilding initramfs.."
    sleep 2
    if xbps-query intel-ucode >/dev/null 2>&1; then
		box "! Intel-ucode already installed \n"
	else
		sudo xbps-install -Sy void-repo-nonfree
		sleep 0.3
		sudo xbps-install -Sy intel-ucode
		sleep 1
		sudo xbps-reconfigure --force linux$(uname -r | cut -d '.' -f 1,2)
		box "Done \n"
	fi
}

### Grub changes ###
grub_commandline() {
    boxf "> Grub mods: silence, speed-up, logo, disable mitigations, disable watchdog"
    sleep 1
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="/&quiet loglevel=3 rd.udev.log_level=3 console=tty2 mitigations=off nowatchdog nmi_watchdog=0 fbcon=nodefer /' /etc/default/grub
    sudo sed -i 's/GRUB_TIMEOUT.*/GRUB_TIMEOUT=1/' /etc/default/grub
    sudo sed -i 's/^#GRUB_BACKGROUND/GRUB_BACKGROUND/' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    box "Done \n"
}

### Fstab ext4 tweaks ###
set_fstab() {
    boxf "> Adding: noatime,commit=60 to fstab for ext4 / partition.."
    sleep 2
    sudo sed -i '/^\S*\s\+\/\s/{s/defaults/&,noatime,commit=60/}' /etc/fstab
    box "Done \n"
}

### Install fonts ###
setup_fonts() {
    boxf "> Installing some fonts.."
    sleep 1
    if fc-list | grep Hack >/dev/null; then 
		box "! Hack already installed \n"
	else
		if command -v curl >/dev/null 2>&1; then
			curl -L https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.0/Hack.zip -o Hack.zip
			if [ ! -f Hack.zip ]; then
				box "\e[1;31m! ERROR: Font download failed.."
			else
				unzip Hack.zip -d ./Hack
				[ ! -d ~/.local/share/fonts/ ] && mkdir -p ~/.local/share/fonts/
				mv ./Hack ~/.local/share/fonts/
				rm Hack.zip
				fc-cache -f
			fi
		else
			box "\e[1;31m! ERROR: curl not found!"
			box "\e[1;31m! please install curl..!"
		fi
	fi
	boxf "> Fixing blurry bitmap fonts.."
    sleep 2
    [ ! -f /etc/fonts/conf.d/70-no-bitmaps.conf ] &&  sudo ln -sv /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
    sudo xbps-reconfigure -f fontconfig
    box "Done \n"
}

### Load GNOME Settings ###
load_gnome_settings() {
	currentDE="$( echo $XDG_CURRENT_DESKTOP )"
	echo "$currentDE detected."
	case $currentDE in
		"GNOME")
			boxf "\e[1;31m> Next step will load GNOME settings, is this ok? [Y/N]"
			read -r accept
			if [[ "$accept" == [Y/y] ]];
			then
				if command -v dconf >/dev/null 2>&1; then
					box "> Loading gnome settings.."
					sleep 1
					dconf load /org/gnome/ < ./resources/gnome_settings
					box "Done \n"
				else
					box "\e[1;31m! ERROR: dconf not found!"
				fi
				[ ! -d ~/.config/autostart/ ] && mkdir -p ~/.config/autostart/
				cp -vf ./resources/myonlogin.desktop ~/.config/autostart/
                sed -i 's@/home/john/@/home/$(whoami)/@' ~/.config/autostart/myonlogin.desktop
			else
				box "> That's ok, you want to make it your own!"
				exit
			fi
			;;
		*)
		box "\e[1;31m Unsupported DE/WM"
			;;
	esac
}

load_dotfiles(){
    boxf "\e[1;31m> Do you want to apply my dotfiles? [Y/N]"
    read -r accept
    if [[ "$accept" == [Y/y] ]]; then
		git clone https://github.com/imatsatsos/dotfiles.git
		if [ -d dotfiles/ ]; then
			chmod a+x ./dotfiles/setup_bash.sh
			source ./dotfiles/setup_bash.sh
			#rm -rf ./dotfiles/
		else
			box "\e[1;31m! ERROR: git clone failed!"
		fi
	fi
}

###  MAIN  ###

num_steps=12

check_root
opening
check_deps

disable_services
box "[progress: 1/$num_steps]"
disable_autostarts
box "[progress: 2/$num_steps]"
remove_packages
box "(progress: 3/$num_steps]"
set_modprobe_bl
set_intel_optim
box "[progress: 4/$num_steps]"
set_io_schedulers
set_ntfs3
box "[progress: 5/$num_steps]"
sv_intel_undervolt
box "[progress: 6/$num_steps]"
gaming_tweaks
box "[progress: 7/$num_steps]"
purge_kernels
box "[progress: 8/$num_steps]"
intel_microcode
box "[progress: 9/$num_steps]"
grub_commandline
box "[progress: 10/$num_step]"
set_fstab
box "[progress: 11/$num_steps]"
setup_fonts
box "[progress: 12/$num_steps]"
load_gnome_settings
load_dotfiles

boxf "> Running a trim on all supported disks.."
sudo fstrim -va

boxu "============= WE ARE DONE! =============="
boxd "            Please reboot !!!            "
sleep 1
