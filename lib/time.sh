# shellcheck shell=bash

# Portable date/time helpers. These avoid GNU-only `date -d` and BSD-only
# `date -v`/`date -j -f` by doing the arithmetic in the shell, so they behave
# identically on Linux, macOS and the BSDs.

# Days from the Unix epoch (1970-01-01) to a proleptic-Gregorian Y/M/D, via
# Howard Hinnant's days_from_civil algorithm. Pure integer arithmetic. Args are
# plain integers, so strip any leading zeros first (e.g. "$((10#$mm))") to avoid
# them being read as octal.
tp_days_from_civil() {
	local year="$1" month="$2" day="$3" era year_of_era day_of_year day_of_era
	[ "$month" -le 2 ] && year=$((year - 1))
	era=$((year / 400))
	year_of_era=$((year - era * 400))
	if [ "$month" -gt 2 ]; then
		day_of_year=$(((153 * (month - 3) + 2) / 5 + day - 1))
	else
		day_of_year=$(((153 * (month + 9) + 2) / 5 + day - 1))
	fi
	day_of_era=$((year_of_era * 365 + year_of_era / 4 - year_of_era / 100 + day_of_year))
	echo $((era * 146097 + day_of_era - 719468))
}

# Parse an ISO 8601 timestamp ($1) to a Unix epoch (UTC seconds), honouring the
# timezone offset. Done by hand (see tp_days_from_civil) rather than via GNU
# `date -d` / BSD `date -j -f`, so it is portable. Fractional seconds and the
# timezone are optional; a bare "Z", or no zone at all, is treated as UTC.
# Echoes nothing and returns 1 when $1 is not a recognisable ISO 8601 timestamp.
tp_iso8601_to_epoch() {
	local input="$1" offset=0
	# e.g. 2026-07-27T15:30:00.123456+00:00, or ...Z, or ...+0200.
	# End-anchored ($) so trailing junk (e.g. "...Zfoo") is rejected, not parsed.
	local pattern='^([0-9]{4})-([0-9]{2})-([0-9]{2})T([0-9]{2}):([0-9]{2}):([0-9]{2})(\.[0-9]+)?(Z|([+-])([0-9]{2}):?([0-9]{2}))?$'
	[[ "$input" =~ $pattern ]] || return 1

	# Name the captured fields (base-10 so leading zeros are not read as octal).
	local year=$((10#${BASH_REMATCH[1]})) month=$((10#${BASH_REMATCH[2]})) day=$((10#${BASH_REMATCH[3]}))
	local hour=$((10#${BASH_REMATCH[4]})) minute=$((10#${BASH_REMATCH[5]})) second=$((10#${BASH_REMATCH[6]}))
	local tz_sign="${BASH_REMATCH[9]}" tz_hour="${BASH_REMATCH[10]}" tz_minute="${BASH_REMATCH[11]}"

	# The date/time fields read as a wall clock in UTC ...
	local days epoch
	days="$(tp_days_from_civil "$year" "$month" "$day")"
	epoch=$((days * 86400 + hour * 3600 + minute * 60 + second))

	# ... then subtract the zone offset (empty/"Z" means UTC) for the true epoch.
	if [ -n "$tz_sign" ]; then
		offset=$((10#$tz_hour * 3600 + 10#$tz_minute * 60))
		[ "$tz_sign" = "-" ] && offset=$((-offset))
	fi
	echo $((epoch - offset))
}

# Seconds from now until an ISO 8601 timestamp ($1), floored at 0 (a time in the
# past yields 0). Echoes 0 when $1 is empty or unparseable.
tp_seconds_until_iso8601() {
	local epoch remaining
	epoch="$(tp_iso8601_to_epoch "$1")" || { echo 0; return 0; }
	remaining=$((epoch - $(date +%s)))
	[ "$remaining" -lt 0 ] && remaining=0
	echo "$remaining"
}

# Format a number of seconds ($1) as a clock duration h:mm (e.g. 3:48, 0:48).
tp_seconds_to_hm() {
	local seconds="$1" hours minutes
	hours=$((seconds / 3600))
	minutes=$(((seconds % 3600) / 60))
	printf '%d:%02d\n' "$hours" "$minutes"
}

# Format a number of seconds ($1) as days/hours (e.g. 4d6h, or 6h under a day).
tp_seconds_to_dh() {
	local seconds="$1" days hours
	days=$((seconds / 86400))
	hours=$(((seconds % 86400) / 3600))
	if [ "$days" -gt 0 ]; then echo "${days}d${hours}h"; else echo "${hours}h"; fi
}
