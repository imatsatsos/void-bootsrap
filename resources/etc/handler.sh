#!/bin/sh
# Default acpi script that takes an entry for all actions

# NOTE: This is a 2.6-centric script.  If you use 2.4.x, you'll have to
#       modify it to not use /sys

#notify-send as root
notify_send() {
    title="$1"
    shift 1
    body="$*"

    for pid in $(pgrep 'i3'); do
        eval $(grep -zw ^USER /proc/$pid/environ)
        eval export $(grep -z ^DISPLAY /proc/$pid/environ)
        eval export $(grep -z ^DBUS_SESSION_BUS_ADDRESS /proc/$pid/environ)
        su $USER -c "notify-send -t 1000 \"$title\" \"$body\""
    done
}

#lock as root? NOT WORKING
lock()
{
    for pid in $(pgrep 'i3'); do
        eval $(grep -zw ^USER /proc/$pid/environ)
        eval export $(grep -z ^DISPLAY /proc/$pid/environ)
        eval export $(grep -z ^DBUS_SESSION_BUS_ADDRESS /proc/$pid/environ)
        su $USER -c "/home/$USER/.config/i3/scripts/i3exit lock"
    done
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
	
		printf '%s' "$(( $brightness $1 step ))" >$brightness_file
		if command -v bc >/dev/null; then
			perc=$(echo "scale=2;$brightness/$max_brightness*100" | bc)
			notify_send "Brightness: $perc%"
		else
			notify_send "Brightness: $1"
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
		#"/home/john/.config/i3/scripts/i3exit lock"
		lock
		sleep 1
                #zzz
                ;;
            *)  logger "ACPI action undefined: $2" ;;
        esac
        ;;
    ac_adapter)
        case "$2" in
            AC|ACAD|ADP0|ACPI*)
                case "$4" in
                    00000000)
                        #echo -n 125 > /sys/class/backlight/intel_backlight/brightness
			printf '125' >/sys/class/backlight/intel_backlight/brightness
			notify_send "AC: Disconnected"
			#printf '%s' "$minspeed" >"$setspeed"
                        #/etc/laptop-mode/laptop-mode start
                    ;;
                    00000001)
			#echo -n 12125 > /sys/class/backlight/intel_backlight/brightness
			printf '12125' >/sys/class/backlight/intel_backlight/brightness
			notify_send "AC: Connected"
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
                lock
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
