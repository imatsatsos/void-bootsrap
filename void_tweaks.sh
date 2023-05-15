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
    boxf "                   !!!!  IMPORTANT  !!!!                    "
    boxu " THIS SCRIPT HEAVILY MODIFIES CORE SERVICES OF THE GNOME DE "
    box "   AND APPLIES MY PREFFERED SETUP TO A VOID LINUX SYSTEM.   "
    box " YOU SHOULD ONLY RUN THIS AFTER INSTALLING GNOME DE ON VOID "
    boxd "            Do you still want to continue? [Y/N]            "
    read -r accept
    if [[ "$accept" == [Y/y] ]];
    then
        box "OK! Lets get started!"
    else
        box "That's ok, thanks for checking out this script"
        exit
    fi
}

check_deps() {
    if command -v curl &> /dev/null && command -v git &> /dev/null
    then
        box "Dependencies found!"
    else
		box "Installing dependencies.."
        for pkmgr in xbps-install pacman; do
            type -P "$pkmgr" &> /dev/null || continue
            case $pkmgr in
                xbps-install)
                    sudo xbps-install -Sy curl git
                    ;;
                pacman)
                    sudo pacman -S curl git
                    ;;
            esac
            return
        done 
    fi
}

### Disable useless services (for a laptop) ###
disable_services() {
    box "> Disabling useless services.."
    sleep 2
    [ -d /var/service/wpa_supplicant ] &&  sudo rm -v /var/service/wpa_supplicant
    [ -d /var/service/dhcpcd ] && sudo rm -v /var/service/dhcpcd
    [ -d /var/service/sshd ] && sudo rm -v /var/service/sshd
}

### Disable gnome autostarts ###
disable_gnome_autostarts() {    
    box "> Disabling useless gnome autostarts.."
    sleep 2
    [ ! -d ~/.config/autostart/ ] &&  mkdir -p ~/.config/autostart/
    [ ! -f ~/.config/autostart/zeitgeist-datahub.desktop ] && cp -v /etc/xdg/autostart/zeitgeist-datahub.desktop ~/.config/autostart/
    echo "Hidden=true" >> ~/.config/autostart/zeitgeist-datahub.desktop
    [ ! -f ~/.config/autostart/org.gnome.SettingsDaemon.Wacom.desktop ] && cp -v /etc/xdg/autostart/org.gnome.SettingsDaemon.Wacom.desktop ~/.config/autostart/
    echo "Hidden=true" >> ~/.config/autostart/org.gnome.SettingsDaemon.Wacom.desktop
    [ ! -f ~/.config/autostart/org.gnome.SettingsDaemon.A11ySettings.desktop ] && cp -v /etc/xdg/autostart/org.gnome.SettingsDaemon.A11ySettings.desktop ~/.config/autostart/
    echo "Hidden=true" >> ~/.config/autostart/org.gnome.SettingsDaemon.A11ySettings.desktop
    [ ! -f ~/.config/autostart/org.gnome.Evolution-alarm-notify.desktop ] && cp -v /etc/xdg/autostart/org.gnome.Evolution-alarm-notify.desktop ~/.config/autostart/
    echo "Hidden=true" >> ~/.config/autostart/org.gnome.Evolution-alarm-notify.desktop
    #[ ! -f ~/.config/autostart/tracker-miner-fs-3.desktop ] && cp -v /etc/xdg/autostart/tracker-miner-fs-3.desktop ~/.config/autostart/
    #echo "Hidden=true" >> ~/.config/autostart/tracker-miner-fs-3.desktop
}

### Fix blurry fonts ###
fix_blurry_fonts() {
    box "> Fixing blurry bitmap fonts.."
    sleep 2
    sudo ln -sv /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
    sudo xbps-reconfigure -f fontconfig
}

### Remove useless packages ###
remove_packages() {
    box "> Removing useless packages.."
    sleep 2
    sudo cp -v ./resources/99-ignored-pkgs.conf /etc/xbps.d/99-ignored-pkgs.conf
    sudo xbps-remove -Fy linux-firmware-amd linux-firmware-broadcom mobile-broadband-provider-info ipw2200-firmware ipw2100-firmware
}

### Set io-schedulers ###
set_io_schedulers() {
    box "> Setting io-schedulers.."
    sleep 2
    [ ! -d /etc/udev/rules.d/ ] && sudo mkdir -p /etc/udev/rules.d/
    sudo cp -v ./resources/60-ioschedulers.rules /etc/udev/rules.d/60-ioschedulers.rules
}

### Set modprobe blacklist ###
set_modprobe_bl() {
    box "> Setting modprobe.."
    sleep 2
    [ ! -d /etc/modprobe.d/ ] && mkdir -p /etc/modprobe.d/
    sudo cp -v ./resources/modprobe.conf /etc/modprobe.d/modprobe.conf
}

### Create intel-undervolt service ###
sv_intel_undervolt() {
    box "> Creating intel-undervolt service and setting undervolt conf.."
    sleep 2
    sudo xbps-install -y intel-undervolt
    sudo cp ./resources/intel-undervolt.conf /etc/intel-undervolt.conf
    [ ! -d /etc/sv/intel-undervolt/ ] && sudo mkdir -p /etc/sv/intel-undervolt/
    sudo cp -fv ./resources/intel-undervolt/run /etc/sv/intel-undervolt/run
    sudo chmod +x /etc/sv/intel-undervolt/run
    sudo ln -s /etc/sv/intel-undervolt /var/service/
}

### Gaming tweaks ###
gaming_tweaks() {
    # vm.max_map_count
    box "> Setting vm.max_map_count.."
    sleep 1.5
    echo "vm.max_map_count=2147483642" | sudo tee -a /etc/sysctl.conf
    # enable Esync
    box "> Enabling Esync.."
    sleep 1.5
    echo "$(whoami) hard nofile 524288" | sudo tee -a /etc/security/limits.conf
}

### Purge old kernels
purge_kernels() {
    box "> Purging old kernels.."
    sleep 2
    sudo xbps-remove -y linux5.19 >/dev/null
    sudo vkpurge rm all
}

### Install intel microcode and rebuild initramfs ###
intel_microcode() {
    box "> Installing intel-ucode and rebuilding initramfs.."
    sleep 2
    if xbps-query intel-ucode >/dev/null 2>&1; then
		echo "> Intel-ucode already installed"
	else
		sudo xbps-install -Sy void-repo-nonfree
		sleep 0.3
		sudo xbps-install -Sy intel-ucode
		sleep 1
		sudo xbps-reconfigure --force linux$(uname -r | cut -d '.' -f 1,2)
	fi
}

### Grub changes ###
grub_commandline() {
    boxu "> Adding: quiet loglevel=3 rd.udev.log_level=3 console=tty2 mitigations=off nowatchdog nmi_watchdog=0 to grub.."
    sleep 1
    sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="/&quiet loglevel=3 rd.udev.log_level=3 console=tty2 mitigations=off nowatchdog nmi_watchdog=0 /' /etc/default/grub
    boxd "> Setting grub timeout to 1 sec.."
    sudo sed -i 's/GRUB_TIMEOUT.*/GRUB_TIMEOUT=1/' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
}

### Fstab ext4 tweaks ###
set_fstab() {
    box  "> Adding: noatime,commit=60 to fstab for ext4 / partition.."
    sleep 2
    sudo sed -i '/^\S*\s\+\/\s/{s/defaults/&,noatime,commit=60/}' /etc/fstab
}

### Install fonts ###
install_fonts() {
    box "> Installing some fonts.."
    sleep 1
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
}

### Load GNOME Settings ###
load_gnome_settings() {
    box "\e[1;31m> Next step will load GNOME settings, is this ok? [Y/N]"
    read -r accept
    if [[ "$accept" == [Y/y] ]];
    then
		box "> Loading gnome settings.."
		sleep 1
		dconf load /org/gnome/ < ./resources/gnome_settings
    else
        box "> That's ok, you want to make it your own!"
        exit
    fi
}

load_dotfiles(){
    box "\e[1;31m> Do you want to apply my dotfiles? [Y/N]"
    read -r accept
    if [[ "$accept" == [Y/y] ]]; then
		git clone https://github.com/imatsatsos/dotfiles.git
		if [ -d dotfiles/ ]; then
			chmod a+x ./dotfiles/setup_bash.sh
			source ./dotfiles/setup_bash.sh
			rm -rf ./dotfiles/
		else
			box "\e[1;31m! ERROR: git clone failed!"
		fi
	fi
}

###  MAIN  ###

num_steps=13

check_root
opening
check_deps

box "(progress: 1/$num_steps)"
disable_services
box "(progress: 2/$num_steps)"
disable_gnome_autostarts
box "(progress: 3/$num_steps)"
remove_packages
box "(progress: 4/$num_steps)"
set_modprobe_bl
box "(progress: 5/$num_steps)"
set_io_schedulers
box "(progress: 6/$num_steps)"
sv_intel_undervolt
box "(progress: 7/$num_steps)"
gaming_tweaks
box "(progress: 8/$num_steps)"
purge_kernels
box "(progress: 9/$num_steps)"
intel_microcode
box "(progress: 10/$num_steps)"
grub_commandline
box "(progress: 11/$num_steps)"
set_fstab
box "(progress: 12/$num_steps)"
install_fonts
box "(progress: 13/$num_steps)"
fix_blurry_fonts

load_gnome_settings
load_dotfiles

box "> Running a trim on all supported disks.."
sudo fstrim -va

boxu "============= WE ARE DONE! =============="
boxd "            Please reboot !!!            "
sleep 1
