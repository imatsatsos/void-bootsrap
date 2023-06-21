# Void Linux Bootstrap
### 1_void_boostrap.sh
Run this first, after installing a minimal version of Void Linux. It will provide you with the option to choose a DE or WM to install. It will install drivers for an Intel and/or Nvidia graphic's card. Audio is being handled by pipewire and wireplumber. The bootstrap scripts try's to be very minimal in the packages it installs as to leave the user with a working but highly configurable system to his/her's preferences.
Currently available DE/WM choices are: Gnome, Plasma, i3, sway, dwm.

### 2_setup_components.sh
A menu selection of various system components to help the user setup the system further according to his/her needs. Options are:
- Setup audio (pipewire w/ wireplumber)
- Setup Acpid and Elogind
	Make both daemon's compatible with each other. acpid will handle acpi events and elogind will provide seat management.
- Install Nvidia drivers.
- Install or update Envycontrol, a utility to handle switching between integrated, hybrid and dediacted GPU modes on Optimus enabled laptops.
- Setup Void Source packages.
	Enable's the usage of building and installing packages from the Void source packages github repository.
	
### 3_tweaks.sh
A handly script that applies my preference of tweaks. It is advised you read and understand it before running it. The script is well tested and should not make your system unbootable, but there is only so much testing I can do. A list of those tweaks follows:
- Disable services: wpa_supplicant, dhcpcd, sshd, agetty-tty{3-6}
- Disable some of Gnome's autostarts
- Remove packages: linux-firmware-amd, linux-firmware-broadcom, mobile-broadband-provider-info, ipw2200-firmware, ipw2100-firmware
- Set io schedulers: 'bfq' for HDD and SSD, 'none' for NVME
- Enable auto unlocking on login of gnome-keyring in Window Managers.
- Enable's mounting of NTFS filesystems using kernel mod.
- Enable a modprobe blacklist in an attempt to make the system more secure.
- Apply config files to X11 to disable mouse acceleration and enable tap-to-click and natural-scrolling on touchpads.
- Install, activate and configure intel-undervolt.
- Setup some performance enhancing tweaks: set vm.max_map_count to 2147483642, enable E-Sync
- Install and set tty font to Terminus 24 Bold
- Remove old installed and unused kernels.
- Set GRUB timeout to 1 sec
- Set GRUB background to Void logo
- Quiet GRUB, disable cpu mitigations, disable watchdog in an attempt to speed up boot times and enhance system performance, although it can decrease security.
- If the filesystem of root is Ext4, then set the fstab options to commit=60, noatime to speed up and help prolong SSD life.
- Enable fontconfig to fix blurry bitmap fonts.
- If the script detect's an active GNOME Session then it will offer to setup some basic gnome settings such as: dark theme, show weekday on bar, etc.
- Finally the script offers an one button installation of imatsatsos' dotfiles.

### 4_install_apps.sh
A menu selection enabling the installation of various apps.
Most notably these include:
- Steam
- Flatpak with Flathub repo
- Virt-Manager for creating and running Virtual Machines
- A collection of apps, such as: Neovim, Geany, Alacritty, Lutris, Htop, yt-dlp, ffmpeg, mpv, ripgrep, MangoHud.. and more.
- A collection of flatpaks, such as: Brave Browser, Flatseal, Spotify, Signal, QBittorrent, Joplin, Handbrake.. and more.
