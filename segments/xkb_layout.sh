# Print the currently used keyboard layout
# This depends on a specifically developed program which prints the group id of
# the currently used layout.
# I developed the simple program myself with some guidance as I was unable to
# find anything already developed.
# Some people might suggest:
# $ setxkbmod -query -v | awk -F "+" '{print $2}'
# this will only work if you have set up XKB with a single layout which is true
# for some.
# On macOS `issw` is used instead (https://github.com/vovkasm/input-source-switcher)

# This script will print the correct layout even if layout is set per window.
# Exit if platform is not linux or macOS as this script is dependant on X11

run_segment() {
	if ! shell_is_linux && ! shell_is_osx; then
		return 1
	fi

	if shell_is_linux; then
		cd "$TMUX_POWERLINE_DIR_SEGMENTS"
		if [ ! -x "xkb_layout" ]; then
			make clean xkb_layout &>/dev/null
		fi

		if [ ! -x ./xkb_layout ]; then
			return 1
		fi
		cur_layout_nbr=$(($(./xkb_layout)+1));
		cur_layout=$(setxkbmap -query | grep layout | sed 's/layout:\s\+//g' | \
			awk -F ',' '{print $'$(echo "$cur_layout_nbr")'}')
	else
		if ! which issw >/dev/null 2>&1; then
			return 1
		fi
		cur_layout="$(issw | awk -F'.' '{ print tolower($NF) }')"
		case $cur_layout in
			uswithumlauts)
				cur_layout="US"
				;;
			german)
				cur_layout="DE"
				;;
			*)
				;;
		esac
	fi

	echo "⌨ $cur_layout"
}
