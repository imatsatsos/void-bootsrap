#!/bin/bash
################################################################################
# Author: 	imatsatsos                                                         #
# Description:	This script will apply the tweaks I use on a Void Linux system #
################################################################################

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

boxerr() {
    title=" $1 "
    echo -e "\e[1;31m$title\e[0m"
}

boxd() {
    title=" $1 "
    edge=$(echo "$title" | sed 's/./*/g')
    echo -e "\e[1;32m$title\e[0m"
    echo "$edge"
}

command_exists () {
    command -v $1 >/dev/null 2>&1;
}


### Check if Script is Run as Root ###
if [[ "$EUID" = 0 ]]; then
    box "Please rerun this as a regular user!" 2>&1
    sleep 2
    exit 1
fi


### OPENING
boxu "                   !!!!  IMPORTANT  !!!!                    "
boxu "   THIS SCRIPT MODIFIES SERVICES, APPLICATION AUTOSTARTS,   "
box  "   REMOVES APPS, TWEAKS SETTINGS AND APPLIES MY PREFFERED   "
box  " SETUP TO A VOID LINUX SYSTEM. !READ IT BEFORE RUNNING IT!  "
boxd "            Do you still want to continue? [y/N]            "
read -r accept
if [[ "$accept" == [Y/y] ]];
then
    box "OK! Lets get started! \n"
else
    box "That's ok, thanks for checking out this script. \n"
    exit
fi


### Check dependencies
if command_exists git && command_exists curl
then
    box "Dependencies found! \n"
else
    boxf "> Installing dependencies.."
    for pkmgr in xbps-install pacman; do
        type -P "$pkmgr" &> /dev/null || continue
        case $pkmgr in
            xbps-install)
                sudo xbps-install -Sy git curl
                box "Done \n"
                ;;
            pacman)
                sudo pacman -Suy git curl
                ;;
        esac
        return
    done 
fi


### Disable useless services (for a laptop) ###
boxf "> Disabling useless services.."
sleep 2
[ -d /var/service/wpa_supplicant ] 	&& sudo rm -v /var/service/wpa_supplicant
[ -d /var/service/dhcpcd ] 			&& sudo rm -v /var/service/dhcpcd
[ -d /var/service/sshd ] 			&& sudo rm -v /var/service/sshd
[ -d /var/service/agetty-tty6 ]     && sudo rm -v /var/service/agetty-tty6
[ -d /var/service/agetty-tty5 ]     && sudo rm -v /var/service/agetty-tty5
[ -d /var/service/agetty-tty4 ]     && sudo rm -v /var/service/agetty-tty4
[ -d /var/service/agetty-tty3 ]     && sudo rm -v /var/service/agetty-tty3
box "Done \n"


### Disable autostarts, mainly gnome ###
boxf "> Disabling useless autostarts (.desktop).."
sleep 2
SYS_AUTOSTART="/etc/xdg/autostart"
USER_AUTOSTART="$HOME/.config/autostart/"
[ ! -d ${USER_AUTOSTART} ] &&  mkdir -p ${USER_AUTOSTART}
if [ -f ${SYS_AUTOSTART}/zeitgeist-datahub.desktop ]; then
    cp -fv ${SYS_AUTOSTART}/zeitgeist-datahub.desktop 				${USER_AUTOSTART}
    echo "Hidden=true" >> ${USER_AUTOSTART}/zeitgeist-datahub.desktop
fi
if [ -f ${SYS_AUTOSTART}/org.gnome.SettingsDaemon.Wacom.desktop ]; then
    cp -fv ${SYS_AUTOSTART}/org.gnome.SettingsDaemon.Wacom.desktop 	${USER_AUTOSTART}
    echo "Hidden=true" >> ${USER_AUTOSTART}/org.gnome.SettingsDaemon.Wacom.desktop
fi
if [ -f ${SYS_AUTOSTART}/org.gnome.SettingsDaemon.A11ySettings.desktop ]; then
    cp -fv ${SYS_AUTOSTART}/org.gnome.SettingsDaemon.A11ySettings.desktop ${USER_AUTOSTART}
    echo "Hidden=true" >> ${USER_AUTOSTART}/org.gnome.SettingsDaemon.A11ySettings.desktop
fi
if [ -f ${SYS_AUTOSTART}/org.gnome.Evolution-alarm-notify.desktop ]; then
    cp -fv ${SYS_AUTOSTART}/org.gnome.Evolution-alarm-notify.desktop ${USER_AUTOSTART}
    echo "Hidden=true" >> ${USER_AUTOSTART}/org.gnome.Evolution-alarm-notify.desktop
fi
#if [ ! -f ~/.config/autostart/tracker-miner-fs-3.desktop ]; then
#   cp -v /etc/xdg/autostart/tracker-miner-fs-3.desktop ~/.config/autostart/
#   echo "Hidden=true" >> ~/.config/autostart/tracker-miner-fs-3.desktop
#fi
box "Done \n"


### Remove useless packages ###
boxf "> Removing useless packages.."
sleep 2
sudo cp -v ./resources/etc/99-ignored-pkgs.conf /etc/xbps.d/99-ignored-pkgs.conf
sudo xbps-remove -Fy mdadm linux-firmware-amd linux-firmware-broadcom mobile-broadband-provider-info ipw2200-firmware ipw2100-firmware
box "Done \n"


### Set io-schedulers ###
boxu "> Setting io-schedulers.."
boxd " bfq -> HDD/SSD, none -> NVMe"
sleep 2
[ ! -d /etc/udev/rules.d/ ] && sudo mkdir -p /etc/udev/rules.d/
sudo cp -v ./resources/udev/60-ioschedulers.rules /etc/udev/rules.d/60-ioschedulers.rules
box "Done \n"


## Setup gnome-keyring to autounlock on login using PAM ###
boxf "> Making gnome-keyring auto-unlock when used with a WM"
sleep 2
sudo cp -fv ./resources/etc/login /etc/pam.d/
box "Done \n"


### Set ntfs3 kernel mod for default ntfs mounting ###
boxf "> Setting ntfs3 kernel by default for mounting ntfs drives.."
sleep 2
[ ! -d /etc/udev/rules.d/ ] && sudo mkdir -p /etc/udev/rules.d/
sudo cp -v ./resources/udev/ntfs3_default.rules /etc/udev/rules.d/ntfs3_default.rules
box "Done \n"


### Set modprobe blacklist ###
boxf "> Setting modprobe blacklist.."
sleep 2
[ ! -d /etc/modprobe.d/ ] && mkdir -p /etc/modprobe.d/
sudo cp -v ./resources/modprobe/modprobe.conf /etc/modprobe.d/modprobe.conf
box "Done \n"


### Set xorg confs (mouse accel, touchpad, keyboard, benq-res, etc) ###
boxf "> Setting xorg.conf.d.."
sleep 2
[ ! -d /etc/X11/xorg.conf.d ] && sudo mkdir -p /etc/X11/xorg.conf.d/
sudo cp -v ./resources/xorg/* /etc/X11/xorg.conf.d/
box "Done \n"


### Optimize Intel Graphics with modprobe ###
## according to arch wiki fastboot and enable_fbc are enabled for my chip (coffe lake)
boxf "> Optimizing Intel Graphics with modprobe.."
sleep 2
[ ! -d /etc/modprobe.d/ ] && mkdir -p /etc/modprobe.d/
sudo cp -v ./resources/modprobe/intel-graphics.conf /etc/modprobe.d/intel-graphics.conf
box "Done \n"


### Create intel-undervolt service ###
boxf "> Creating intel-undervolt service and /etc/intel-undervolt.conf.."
sleep 2
if command -v intel-undervolt &> /dev/null; then
    box "! intel-undervolt already installed \n"
else
    sudo xbps-install -Sy intel-undervolt
fi
sudo cp -v ./resources/etc/intel-undervolt.conf /etc/intel-undervolt.conf
if [ -d "/etc/sv/intel-undervolt/" ]; then
    box "! intel-undervolt service already configured \n"
else
    sudo mkdir -p /etc/sv/intel-undervolt/
    sudo cp -fv ./resources/intel-undervolt/run /etc/sv/intel-undervolt/run
    sudo chmod +x /etc/sv/intel-undervolt/run
    sudo ln -s /etc/sv/intel-undervolt /var/service/
    sudo cp -f ./resources/etc/zzz.d/1-intel-undervolt.sh /etc/zzz.d/resume/
    sudo cp -f ./resources/libexec/00-intel-undervolt.sh /usr/libexec/elogind/system-sleep/
    box "Done \n"
fi


### Gaming tweaks ###
boxf "> Setting vm.max_map_count, Enabling Esync.."
sleep 2
# vm.max_map_count
echo "vm.max_map_count=2147483642" | sudo tee -a /etc/sysctl.conf
# enable Esync
sleep 1
echo "$(whoami) hard nofile 524288" | sudo tee -a /etc/security/limits.conf
box "Done \n"


### rc.conf changes ###
boxf "> Setting terminus 20b tty font.."
sleep 2
if [ ! -f /usr/share/kbd/consolefonts/ter-120b.psf.gz ]; then
    sudo xbps-install -Sy terminus-font
fi
sudo sed -i.bak 's/^#FONT=.*/FONT="ter-120b"/' /etc/rc.conf
box "Done \n"


## Fix blurry fonts ###
sudo ln -s /usr/share/fontconfig/conf.avail/70-no-bitmaps.conf /etc/fonts/conf.d/
sudo xbps-reconfigure -f fontconfig


### Purge old kernels ###
boxf "> Purging old kernels.."
sleep 2
sudo xbps-remove -y linux5.19 2>&1
sudo vkpurge rm all
box "Done \n"


### Install intel microcode and rebuild initramfs ###
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


### Grub changes ###
boxf "> Grub tweaks: silence, speed-up, logo, disable mitigations, disable watchdog"
sleep 2
sudo sed -i.bak 's/^GRUB_CMDLINE_LINUX_DEFAULT="/&quiet loglevel=3 udev.log_level=3 console=tty2 mitigations=off nowatchdog nmi_watchdog=0 msr.allow_writes=on fbcon=nodefer /' /etc/default/grub
sudo sed -i 's/GRUB_TIMEOUT.*/GRUB_TIMEOUT=0/' /etc/default/grub
sudo sed -i 's/^#GRUB_HIDDEN_TIMEOUT.*/GRUB_HIDDEN_TIMEOUT=2/' /etc/default/grub
sudo sed -i 's/^#GRUB_BACKGROUND/GRUB_BACKGROUND/' /etc/default/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg
box "Done \n"


### Fstab ext4 tweaks ###
boxf "> Adding: noatime,commit=60 to fstab for ext4 root (/) partition.."
sleep 2
sudo sed -i.bak '/^\S*\s\+\/\s/{s/defaults/&,noatime,commit=60/}' /etc/fstab
box "Done \n"


### Load GNOME Settings ###
currentDE=$XDG_CURRENT_DESKTOP
case $currentDE in
    "GNOME")
        boxf "\e[1;31m> Next step will load GNOME settings, is this ok? [y/N]"
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
        box "\e[1;31m ..Skipping GNOME settings load..\n"
        ;;
esac


## Load Dotfiles
boxf "\e[1;32m> Do you want to apply imatsatsos' dotfiles? [y/N]"
read -r accept
if [[ "$accept" == [Y/y] ]]; then
    git clone --depth=1 https://github.com/imatsatsos/dotfiles.git || box "\e[1;31m! ERROR: git clone failed!"
    chmod a+x ./dotfiles/setup_dots.sh
    source ./dotfiles/setup_dots.sh
    #rm -rf ./dotfiles/
fi


### TRIM
boxf "> Running a trim on all supported disks.."
sleep 1
sudo fstrim -va


### DONE
boxu "============= WE ARE DONE! =============="
boxd "            Please reboot !!!            "
