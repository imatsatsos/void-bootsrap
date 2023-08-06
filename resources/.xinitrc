sysresources=/etc/X11/xinit/.Xresources
userresources=$HOME/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap
usermodmap=$HOME/.Xmodmap

# merge in defaults and keymaps
[ -f "$sysresources" ] && xrdb -merge $sysresources
[ -f "$userresources" ]  &&  xrdb -merge "$userresources"
[ -f $sysmodmap ] && xmodmap $sysmodmap
[ -f "$usermodmap" ] && xmodmap "$usermodmap"

# start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# source xprofile
[ -f /etc/xprofile ] && . /etc/xprofile
[ -f ~/.xprofile ] && . ~/.xprofile

# set X11 screen resolution
xrandr -s 1920x1080

# set some X11 env variables
export XDG_SESSION_TYPE="x11"

# IMPORTANT, to start dbus and set it's address like in DEs!
[ -z "$DBUS_SESSION_BUS_ADDRESS" ]  && eval $(dbus-launch --sh-syntax)
export DBUS_SESSION_BUS_ADDRESS

# WM apps
pidof -sx "pipewire" || pipewire &
# disabled cause i start pipewire-pulse using /usr/share/pipewire/pipewire.conf last line
#pidof -sx "pipewire-pulse" || pipewire-pulse &
export $(gnome-keyring-daemon --start --components=pkcs11,secrets,gpg)
pidof -sx "polkit-gnome-authentication-agent-1" || "/usr/libexec/polkit-gnome-authentication-agent-1" &
pidof -sx "dwmblocks" || dwmblocks -b &
pidof -sx "low_battery" || low_battery &
pidof -sx "picom" || picom -b &
xwallpaper --maximize ~/.config/background &
pidof -sx "onlogin.sh" || onlogin.sh &
pidof -sx "sxhkd" || sxhkd &

# update dbus environment variables
#dbus-update-activation-environment --systemd DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY
dbus-update-activation-environment DBUS_SESSION_BUS_ADDRESS DISPLAY XAUTHORITY

#autostart="programs"
#for program in $autostart; do
#	pidof -sx "$program" || "$program" &
#done >/dev/null 2>&1

## start window-manager
exec dbus-run-session /usr/local/bin/dwm
# exec dbus-run-session /usr/bin/i3
