#!/bin/env bash

#######################################################################################
# Author: 	imatsatsos                                                                #
# Description:	This script install's my preferred applications in an interactive way #
#######################################################################################
# alacritty       > terminal
# geany           > text editor
# gimp            > image editor
# fsearch         > powerfull searcher
# rofi            > launcher
# rofi-calc       > calc for rofi
# rofi-emoji      > emojis for rofi
# htop            > sys monitor
# neovim          > term text editor
# xclip           > Needed for neovim clipboard
# ripgrep         > poewrfull grep
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
# jq              > json parser
# fzf             > fuzzy search
# ImageMagick     > image cli tools
# gcc             > gnu c compiler
# tree            > tree ls
# wget            > download things
# tessaract       > ocr images
# xephyr          > nested Xorg server
# vsftpd          > very secure ftp daemon
# ranger          > file explorer
# bat             > better cat
# exa             > better ls
# fd              > better find
# spellcheck      > program to test scripts
# vsv             > void service scripts
# xcolor          > x11 color picker

pkgs=("void-repo-nonfree" "void-repo-multilib" "void-repo-multilib-nonfree" \
      "steam libgcc-32bit libstdc++-32bit libdrm-32bit libglvnd-32bit mesa-dri-32bit vulkan-loader-32bit" \
      "nvidia nvidia-vaapi-driver nvidia-libs-32bit" \
      "Signal-Desktop" "firefox" "alacritty" "gimp" "fsearch" "seahorse" "rofi" "rofi-calc" "rofi-emoji" "geany" "mpv" "easyeffects" "handbrake" \
      "pcmanfm" "nsxiv" "neofetch" "lxappearance" "file-roller" "polybar" "i3lock" "sxhkd" "pywal" "wpgtk" \
      "htop" "btop" "nvtop" "intel-gpu-tools" "intel-undervolt" "sysbench" "ncdu" "fuzzypkg" "vsv" "simple-mtpfs" \
      "neovim" "ripgrep" "fd" "fzf" "git" "jq" "spellcheck" "gcc" \
      "xclip" "tree" "bat" "zip" "wget" "ranger" "gpick" "ImageMagick" "xcolor" "yt-dlp" "ffmpeg" "maim" "playerctl" \
      "xorg-server-xephyr" "vsftpd" "tesseract-ocr tesseract-ocr-ell tesseract-ocr-eng" \
      "libvirtd virt-manager qemu" \
      "MangoHud" "lutris" "gamemode" \
      "dejavu-fonts-ttf" "font-awesome6" "font-material-design-icons-ttf" "noto-fonts-emoji" "terminus-font" "wqy-microhei" \
)

for str in "${pkgs[@]}"; do
	echo "$str"
done | fzf --multi --exact --cycle --reverse --preview 'xbps-query -R {1}' | xargs -ro sudo xbps-install

