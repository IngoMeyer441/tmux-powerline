# LICENSE This code is not under the same license as the rest of the project as it's "stolen". It's cloned from https://github.com/richoH/dotfiles/blob/master/bin/battery and just some modifications are done so it works for my laptop. Check that URL for more recent versions.

TMUX_POWERLINE_SEG_BATTERY_TYPE_DEFAULT="percentage"
TMUX_POWERLINE_SEG_BATTERY_NUM_SYMBOLS_DEFAULT=5
TMUX_POWERLINE_SEG_BATTERY_SYMBOL_FULL_DEFAULT="♥"
TMUX_POWERLINE_SEG_BATTERY_SYMBOL_EMPTY_DEFAULT="♡"
TMUX_POWERLINE_SEG_BATTERY_VIEW_THRESHOLD_DEFAULT="100"

generate_segmentrc() {
	read -d '' rccontents  << EORC
# How to display battery remaining. Can be {percentage, cute}.
export TMUX_POWERLINE_SEG_BATTERY_TYPE="${TMUX_POWERLINE_SEG_BATTERY_TYPE_DEFAULT}"
# How many symbols to show if cute indicators are used.
export TMUX_POWERLINE_SEG_BATTERY_NUM_SYMBOLS="${TMUX_POWERLINE_SEG_BATTERY_NUM_SYMBOLS_DEFAULT}"
# Which symbol to use for the percentage view or for a full battery in cute mode.
export TMUX_POWERLINE_SEG_BATTERY_SYMBOL_FULL="${TMUX_POWERLINE_SEG_BATTERY_SYMBOL_FULL_DEFAULT}"
# Which symbol to use in cute mode when the battery is not fully charged.
export TMUX_POWERLINE_SEG_BATTERY_SYMBOL_EMPTY="${TMUX_POWERLINE_SEG_BATTERY_SYMBOL_EMPTY_DEFAULT}"
# Charge level threshold to show the segment. '100' means the segment is always visible.
export TMUX_POWERLINE_SEG_BATTERY_VIEW_THRESHOLD="${TMUX_POWERLINE_SEG_BATTERY_VIEW_THRESHOLD_DEFAULT}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	if shell_is_osx; then
		battery_status=$(__battery_osx)
	else
		battery_status=$(__battery_linux)
	fi
	[ -z "$battery_status" ] && return
	[ "$battery_status" -le "$TMUX_POWERLINE_SEG_BATTERY_VIEW_THRESHOLD" ] || return

	case "$TMUX_POWERLINE_SEG_BATTERY_TYPE" in
		"percentage")
			output="${TMUX_POWERLINE_SEG_BATTERY_SYMBOL_FULL} ${battery_status}%"
			;;
		"cute")
			output=$(__cutinate $battery_status)
	esac
	if [ -n "$output" ]; then
		echo "$output"
	fi
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_BATTERY_TYPE" ]; then
		export TMUX_POWERLINE_SEG_BATTERY_TYPE="${TMUX_POWERLINE_SEG_BATTERY_TYPE_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_BATTERY_NUM_SYMBOLS" ]; then
		export TMUX_POWERLINE_SEG_BATTERY_NUM_SYMBOLS="${TMUX_POWERLINE_SEG_BATTERY_NUM_SYMBOLS_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_BATTERY_SYMBOL_FULL" ]; then
		export TMUX_POWERLINE_SEG_BATTERY_SYMBOL_FULL="${TMUX_POWERLINE_SEG_BATTERY_SYMBOL_FULL_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_BATTERY_SYMBOL_EMPTY" ]; then
		export TMUX_POWERLINE_SEG_BATTERY_SYMBOL_EMPTY="${TMUX_POWERLINE_SEG_BATTERY_SYMBOL_EMPTY_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_BATTERY_VIEW_THRESHOLD" ]; then
		export TMUX_POWERLINE_SEG_BATTERY_VIEW_THRESHOLD="${TMUX_POWERLINE_SEG_BATTERY_VIEW_THRESHOLD_DEFAULT}"
	fi
}

__battery_osx() {
	ioreg -c AppleSmartBattery -w0 | \
		grep -o '"[^"]*" = [^ ]*' | \
		sed -e 's/= //g' -e 's/"//g' | \
		sort | \
		while read key value; do
			case $key in
				"MaxCapacity")
					export maxcap=$value;;
				"CurrentCapacity")
					export curcap=$value;;
				"ExternalConnected")
					export extconnect=$value;;
				"FullyCharged")
					export fully_charged=$value;;
			esac
			if [[ -n $maxcap && -n $curcap && -n $extconnect ]]; then
				if [[ "$curcap" == "$maxcap" || "$fully_charged" == "Yes" && $extconnect == "Yes"  ]]; then
					return
				fi
				charge=`pmset -g batt | grep -o "[0-9][0-9]*\%" | rev | cut -c 2- | rev`
				echo "$charge"
				break
			fi
		done
	}

	__battery_linux() {
		case "$SHELL_PLATFORM" in
			"linux")
				BATPATH=/sys/class/power_supply/BAT0
				if [ ! -d $BATPATH ]; then
					BATPATH=/sys/class/power_supply/BAT1
				fi
				STATUS=$BATPATH/status
				BAT_FULL=$BATPATH/charge_full
				if [ ! -r $BAT_FULL ]; then
					BAT_FULL=$BATPATH/energy_full
				fi
				BAT_NOW=$BATPATH/charge_now
				if [ ! -r $BAT_NOW ]; then
					BAT_NOW=$BATPATH/energy_now
				fi

				if [[ "$1" = `cat $STATUS` || "$1" = "" ]]; then
					__linux_get_bat
				fi
				;;
			"bsd")
				STATUS=`sysctl -n hw.acpi.battery.state`
				case $1 in
					"Discharging")
						if [ $STATUS -eq 1 ]; then
							__freebsd_get_bat
						fi
						;;
					"Charging")
						if [ $STATUS -eq 2 ]; then
							__freebsd_get_bat
						fi
						;;
					"")
						__freebsd_get_bat
						;;
				esac
				;;
		esac
	}

	__cutinate() {
		perc=$1
		inc=$(( 100 / $TMUX_POWERLINE_SEG_BATTERY_NUM_SYMBOLS ))


		for i in `seq $TMUX_POWERLINE_SEG_BATTERY_NUM_SYMBOLS`; do
			if [ $perc -lt 99 ]; then
				echo -n $TMUX_POWERLINE_SEG_BATTERY_SYMBOL_EMPTY
			else
				echo -n $TMUX_POWERLINE_SEG_BATTERY_SYMBOL_FULL
			fi
			echo -n " "
			perc=$(( $perc + $inc ))
		done
	}

	__linux_get_bat() {
		bf=$(cat $BAT_FULL)
		bn=$(cat $BAT_NOW)
		if [ $bn -gt $bf ]; then
			bn=$bf
		fi
		echo $(( 100 * $bn / $bf ))
	}

	__freebsd_get_bat() {
		echo "$(sysctl -n hw.acpi.battery.life)"

	}
