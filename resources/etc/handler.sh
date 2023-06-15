#!/bin/sh
# Default acpi script that takes an entry for all actions

# NOTE: This is a 2.6-centric script.  If you use 2.4.x, you'll have to
#       modify it to not use /sys

#notify-send as root
notify_send() {
    pid=$(pidof 'i3')    
    eval $(grep -zw ^USER /proc/$pid/environ)
    eval export $(grep -z ^DISPLAY /proc/$pid/environ)
    eval export $(grep -z ^DBUS_SESSION_BUS_ADDRESS /proc/$pid/environ)
    
    [ "$1" = "00000000" ] && do_notif "Power" "AC: Disconnected" #&& play_sound "$1"
    [ "$1" = "00000001" ] && do_notif "Power" "AC: Connected"
    
}

# dunstify as root
do_notif() {
    su $USER -c "dunstify -a \"Power\" \
	    \"$1\" \
	    \"$2\" \
	    -r 999 \
	    -t 10000"
}

# play sound as root
play_sound() {
    pid=$(pidof -s 'wireplumber')
    eval $(grep -zw ^USER /proc/$pid/environ)
    eval export $(grep -z ^DISPLAY /proc/$pid/environ)
    eval export $(grep -z ^DBUS_SESSION_BUS_ADDRESS /proc/$pid/environ)
    sounds="/usr/share/sounds/freedesktop/stereo/"
    if [ "$1" = "00000000" ]; then
	su john -c "paplay $sounds/power-unplug.oga"
	echo its0
    elif [ "$1" = "00000001" ]; then
        echo its1
    fi
}

#lock as root
lock()
{
    pid=$(pgrep -x 'i3')
    eval $(grep -zw ^USER /proc/$pid/environ)
    eval export $(grep -z ^DISPLAY /proc/$pid/environ)
    eval export $(grep -z ^DBUS_SESSION_BUS_ADDRESS /proc/$pid/environ)
    su $USER -c "/home/$USER/.config/i3/scripts/i3exit lock"
    #local display=$DISPLAY
    #local user=$(who | grep $display | awk '{print $1}')
    #local uid=$(id -u $user)
    #local addr=$(echo $DBUS_SESSION_BUS_ADDRESS)
    #su $user DISPLAY=$display DBUS_SESSION_BUS_ADDRESS=$addr /home/$user/.config/i3/scripts/i3exit "lock"
}

# $1 should be + or - to step up or down the brightness.
step_backlight() {
	for backlight in /sys/class/backlight/*/; do
		[ -d "$backlight" ] || continue

		max_brightness_file="$backlight/max_brightness"
		brightness_file="$backlight/brightness"
		brightness=$(cat $brightness_file)
		max_brightness=$(cat $max_brightness_file)

		#step is 20% of max_brightness
		step=$(( $max_brightness / 20 ))
		[ "$step" -gt "1" ] || step=10 #fallback if gradation is too low
		
		new_brightness=$(( brightness $1 step ))
		
		if [ "$new_brightness" -gt 24000 ]; then
			printf '24000' >$brightness_file
		else
			printf '%s' "$new_brightness" >$brightness_file
		fi
	done
}

minspeed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_min_freq)
maxspeed=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
setspeed="/sys/devices/system/cpu/cpu0/cpufreq/scaling_setspeed"

# start acpi handling
case "$1" in
    button/power)
        case "$2" in
            PBTN|PWRF)
                logger "PowerButton pressed: $2, shutting down..."
                shutdown -P now
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    button/sleep)
        case "$2" in
            SBTN|SLPB)
                # suspend-to-ram
                logger "Sleep Button pressed: $2, suspending..."
		# lock first then sleep
		lock
		sleep 1
		zzz
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    ac_adapter)
        case "$2" in
            AC|ACAD|ADP0|ACPI*)
                case "$4" in
                    00000000)
			printf '125' >/sys/class/backlight/intel_backlight/brightness
			notify_send "$4"
			#printf '%s' "$minspeed" >"$setspeed"
                        #/etc/laptop-mode/laptop-mode start
                    ;;
                    00000001)
			printf '12125' >/sys/class/backlight/intel_backlight/brightness
			notify_send "$4"
                        #printf '%s' "$maxspeed" >"$setspeed"
                        #/etc/laptop-mode/laptop-mode stop
                    ;;
                esac
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    battery)
        case "$2" in
            BAT0)
                case "$4" in
                    00000000)   #echo "offline" >/dev/tty5
                    ;;
                    00000001)   #echo "online"  >/dev/tty5
                    ;;
                esac
                ;;
            CPU0)
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    button/lid)
        case "$3" in
            close)
                # suspend-to-ram
                logger "LID closed, suspending..."
		# lock first then sleep
		lock
		sleep 1
		zzz
                ;;
            open)
                logger "LID opened"
                ;;
            *)  logger "ACPI action undefined (LID): $2";;
        esac
        ;;
    video/brightnessdown)
        step_backlight -
        ;;
    video/brightnessup)
        step_backlight +
        ;;
    *)
        logger "ACPI group/action undefined: $1 / $2"
        ;;
esac
