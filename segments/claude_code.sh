# shellcheck shell=bash

# shellcheck source=lib/util.sh
source "${TMUX_POWERLINE_DIR_LIB}/util.sh"
# shellcheck source=lib/time.sh
source "${TMUX_POWERLINE_DIR_LIB}/time.sh"

# Where Claude Code stores its OAuth credentials. The access token is read fresh
# on every refresh; Claude Code keeps it valid, so this segment needs no auth of
# its own. If the token is expired (e.g. Claude Code has not run for a while) the
# last cached value is shown instead.
TMUX_POWERLINE_SEG_CLAUDE_CODE_CREDENTIALS_FILE="${TMUX_POWERLINE_SEG_CLAUDE_CODE_CREDENTIALS_FILE:-${HOME}/.claude/.credentials.json}"
TMUX_POWERLINE_SEG_CLAUDE_CODE_UPDATE_INTERVAL="${TMUX_POWERLINE_SEG_CLAUDE_CODE_UPDATE_INTERVAL:-300}"

# Which utilization bars to show (percent of the 5-hour "session" window and the
# 7-day "weekly" window, mirroring Claude Code's /usage).
TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_SESSION="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_SESSION:-yes}"
TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_WEEKLY="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_WEEKLY:-yes}"

# Optional "time remaining" indicators (all off by default):
#   SESSION_TIME - time left in the current 5-hour session window (clock h:mm, e.g. 2:13)
#   WEEKLY_TIME  - time left in the current 7-day weekly window (days/hours, e.g. 4d6h)
#   CYCLE_TIME   - time left in the current payment period (days/hours, e.g. 12d3h)
TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_SESSION_TIME="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_SESSION_TIME:-no}"
TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_WEEKLY_TIME="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_WEEKLY_TIME:-no}"
TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_CYCLE_TIME="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_CYCLE_TIME:-no}"

# Symbols / separators.
TMUX_POWERLINE_SEG_CLAUDE_CODE_SYMBOL="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SYMBOL:-󰚩}"
# SEPARATOR sits between windows (session / weekly / billing). TIME_JOINER joins a
# window's usage figure to its own time-left value (e.g. "10% 3:48"); it is
# tighter than SEPARATOR so each window reads as one unit.
TMUX_POWERLINE_SEG_CLAUDE_CODE_SEPARATOR="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SEPARATOR:- | }"
TMUX_POWERLINE_SEG_CLAUDE_CODE_TIME_JOINER="${TMUX_POWERLINE_SEG_CLAUDE_CODE_TIME_JOINER:- }"
# Time-indicator prefixes. Session/weekly times sit next to their percentage so
# they default to no prefix. CYCLE_TIME_SYMBOL marks the cycle time-left: it
# immediately prefixes that countdown wherever it renders -- leading the billing
# window when cost is off (e.g. "↻5d12h"), or right after the cost figure when
# cost is shown (e.g. "$86.25 ↻5d12h") -- so the countdown reads as the cycle.
TMUX_POWERLINE_SEG_CLAUDE_CODE_SESSION_TIME_SYMBOL="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SESSION_TIME_SYMBOL:-}"
TMUX_POWERLINE_SEG_CLAUDE_CODE_WEEKLY_TIME_SYMBOL="${TMUX_POWERLINE_SEG_CLAUDE_CODE_WEEKLY_TIME_SYMBOL:-}"
TMUX_POWERLINE_SEG_CLAUDE_CODE_CYCLE_TIME_SYMBOL="${TMUX_POWERLINE_SEG_CLAUDE_CODE_CYCLE_TIME_SYMBOL:-↻}"

# Accumulated cost computed by `ccusage` from the Claude Code transcripts in
# ~/.claude/projects. This is a notional "what it would have cost on the
# pay-per-token API" figure (≈ what Claude Code's /usage shows); on a
# subscription you are not actually billed it. Disabled by default because it
# needs ccusage installed (https://github.com/ryoppippi/ccusage).
TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_COST="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_COST:-no}"
# Which cost(s) to show:
#   alltime - total over all sessions found on the system
#   period  - total over the current payment period only
#   both    - all-time total, with the period total in parentheses
# NOTE: ccusage can only sum transcripts still on disk, and Claude Code prunes
# them after cleanupPeriodDays (default 30). So "alltime" is really "since the
# oldest retained transcript" -- raise cleanupPeriodDays in Claude Code's
# settings.json to widen it (it cannot recover already-deleted sessions).
TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_MODE="${TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_MODE:-alltime}"
# Day-of-month the payment period starts (your Max plan renewal day). Used for
# the "period"/"both" modes. Either a number 1-28 (1 = calendar month), or
# "auto" to derive it from the subscription's billing anchor via the API (cached).
# NOTE: the API only exposes the *original* signup date (subscription_created_at);
# it does NOT reflect a later plan change. If you upgraded/downgraded mid-cycle,
# Stripe re-anchors your renewal to the change date, and "auto" will be wrong —
# set the correct day explicitly here. If "auto" cannot reach the API,
# COST_PERIOD_START_FALLBACK_DAY is used.
TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_PERIOD_START_DAY="${TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_PERIOD_START_DAY:-auto}"
TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_PERIOD_START_FALLBACK_DAY="${TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_PERIOD_START_FALLBACK_DAY:-1}"
# Endpoint that exposes the subscription billing anchor (for "auto" above).
TMUX_POWERLINE_SEG_CLAUDE_CODE_PROFILE_URL="${TMUX_POWERLINE_SEG_CLAUDE_CODE_PROFILE_URL:-https://api.anthropic.com/api/oauth/profile}"
TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_UPDATE_INTERVAL="${TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_UPDATE_INTERVAL:-3600}"
# The ccusage command. Default expects it on PATH; you can pin it, e.g.
#   "nix run github:ryoppippi/ccusage/v20.0.6 --"
# or point at a profile/store binary. The "claude daily" subcommand is appended
# so only Claude Code sessions are counted (not codex/gemini/copilot/etc. that
# ccusage would otherwise include). Give only the base command here, without a
# "claude"/"daily" of your own, or the subcommand ends up duplicated.
TMUX_POWERLINE_SEG_CLAUDE_CODE_CCUSAGE_CMD="${TMUX_POWERLINE_SEG_CLAUDE_CODE_CCUSAGE_CMD:-ccusage}"
# Run ccusage offline (use its bundled price table, no network). Recommended.
TMUX_POWERLINE_SEG_CLAUDE_CODE_CCUSAGE_OFFLINE="${TMUX_POWERLINE_SEG_CLAUDE_CODE_CCUSAGE_OFFLINE:-yes}"
# printf format for each cost dollar figure. The billing-window icon, the period
# parentheses and the time-left binding are added structurally around it.
TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_FORMAT="${TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_FORMAT:-\$%.2f}"

# Endpoint that backs Claude Code's /usage limit bars.
TMUX_POWERLINE_SEG_CLAUDE_CODE_API_URL="${TMUX_POWERLINE_SEG_CLAUDE_CODE_API_URL:-https://api.anthropic.com/api/oauth/usage}"

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# Path to Claude Code's OAuth credentials file (access token is read from here).
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_CREDENTIALS_FILE="${TMUX_POWERLINE_SEG_CLAUDE_CODE_CREDENTIALS_FILE}"
# How often (seconds) to refresh the session/weekly limits.
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_UPDATE_INTERVAL="${TMUX_POWERLINE_SEG_CLAUDE_CODE_UPDATE_INTERVAL}"
# Show the 5-hour "session" utilization bar.
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_SESSION="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_SESSION}"
# Show the 7-day "weekly" utilization bar.
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_WEEKLY="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_WEEKLY}"
# Time-remaining indicators: session window (h:mm), weekly window (d/h), payment cycle (d/h).
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_SESSION_TIME="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_SESSION_TIME}"
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_WEEKLY_TIME="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_WEEKLY_TIME}"
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_CYCLE_TIME="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_CYCLE_TIME}"
# Leading symbol, separator between windows, and the tighter joiner that binds a
# window's percentage to its own time-left (e.g. "10% 3:48").
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_SYMBOL="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SYMBOL}"
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_SEPARATOR="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SEPARATOR}"
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_TIME_JOINER="${TMUX_POWERLINE_SEG_CLAUDE_CODE_TIME_JOINER}"
# Prefixes for the time indicators (cycle gets a marker since it stands alone).
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_SESSION_TIME_SYMBOL="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SESSION_TIME_SYMBOL}"
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_WEEKLY_TIME_SYMBOL="${TMUX_POWERLINE_SEG_CLAUDE_CODE_WEEKLY_TIME_SYMBOL}"
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_CYCLE_TIME_SYMBOL="${TMUX_POWERLINE_SEG_CLAUDE_CODE_CYCLE_TIME_SYMBOL}"
# Show accumulated cost via ccusage (https://github.com/ryoppippi/ccusage).
# This requires ccusage to be installed; it is a notional API-equivalent cost.
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_COST="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_COST}"
# Which cost(s) to show: alltime | period | both. Note "alltime" is bounded by
# the transcripts still on disk: Claude Code prunes them after cleanupPeriodDays
# (default 30), so it means "since the oldest retained transcript".
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_MODE="${TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_MODE}"
# Day-of-month the payment period starts: a number 1-28, or "auto" to derive the
# Max renewal day from the subscription billing anchor via the API. "auto" sees
# only the original signup date, not later plan changes — set the day explicitly
# if you upgraded/downgraded mid-cycle.
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_PERIOD_START_DAY="${TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_PERIOD_START_DAY}"
# Day used when COST_PERIOD_START_DAY="auto" but the API is unreachable.
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_PERIOD_START_FALLBACK_DAY="${TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_PERIOD_START_FALLBACK_DAY}"
# How often (seconds) to recompute the cost (ccusage is heavier than the API call).
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_UPDATE_INTERVAL="${TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_UPDATE_INTERVAL}"
# The ccusage command (pin it for reproducibility if you like). The "claude
# daily" subcommand is appended automatically, so give only the base command
# (without "claude"/"daily" yourself) -- only Claude Code sessions are counted.
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_CCUSAGE_CMD="${TMUX_POWERLINE_SEG_CLAUDE_CODE_CCUSAGE_CMD}"
# Run ccusage offline (bundled prices, no network).
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_CCUSAGE_OFFLINE="${TMUX_POWERLINE_SEG_CLAUDE_CODE_CCUSAGE_OFFLINE}"
# printf format for each cost dollar figure.
# export TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_FORMAT="${TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_FORMAT}"
EORC
	echo "$rccontents"
}

run_segment() {
	if ! type curl >/dev/null 2>&1 || ! type jq >/dev/null 2>&1; then
		return 0
	fi

	# The limits block (session/weekly windows) and the billing block (cost and/or
	# cycle time) are each internally joined with SEPARATOR, then joined to each
	# other with the same SEPARATOR so all windows are divided uniformly. The
	# leading segment symbol is applied once, here.
	local limits billing joined="" part
	limits="$(__claude_code_limits)"
	billing="$(__claude_code_cost)"

	# When cost is enabled the cycle countdown normally rides inside the billing
	# window (see __claude_code_render_cost), so __claude_code_limits deliberately
	# does not emit it standalone. But if billing came back empty -- e.g. ccusage
	# is missing or failed on a cold start with no cached figure yet -- that
	# countdown would vanish entirely. Fall back to a standalone cycle window so
	# SHOW_CYCLE_TIME is honoured regardless of the cost path's fate.
	if [ -z "$billing" ] &&
		tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_COST" &&
		tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_CYCLE_TIME"; then
		billing="$(__claude_code_cycle_countdown)"
	fi

	local parts=()
	[ -n "$limits" ] && parts+=("$limits")
	[ -n "$billing" ] && parts+=("$billing")

	for part in "${parts[@]}"; do
		if [ -z "$joined" ]; then
			joined="$part"
		else
			joined="${joined}${TMUX_POWERLINE_SEG_CLAUDE_CODE_SEPARATOR}${part}"
		fi
	done

	[ -z "$joined" ] && return 0
	if [ -n "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SYMBOL" ]; then
		echo "${TMUX_POWERLINE_SEG_CLAUDE_CODE_SYMBOL} ${joined}"
	else
		echo "$joined"
	fi
	return 0
}

__claude_code_limits() {
	# Session/weekly percentages and their resets come from the usage endpoint
	# (which needs the OAuth token); the cycle countdown is derived locally from
	# the renewal day, so it must still render when the token/endpoint is missing.
	local need_usage="no" show_cycle="no"
	tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_SESSION" && need_usage="yes"
	tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_WEEKLY" && need_usage="yes"
	tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_SESSION_TIME" && need_usage="yes"
	tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_WEEKLY_TIME" && need_usage="yes"
	# The cycle time-left rides inside the billing window when cost is shown; only
	# render it as a standalone window here when cost is off.
	if tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_CYCLE_TIME" &&
		! tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_COST"; then
		show_cycle="yes"
	fi

	if [ "$need_usage" = "no" ] && [ "$show_cycle" = "no" ]; then
		return 0
	fi

	local parts=()

	# Usage windows (cached; falls back to the last value -- or nothing -- when
	# the token/endpoint is unavailable).
	if [ "$need_usage" = "yes" ]; then
		local windows
		windows="$(__claude_code_usage_windows)"
		[ -n "$windows" ] && parts+=("$windows")
	fi

	# Standalone cycle countdown: local and cheap, so it is computed fresh every
	# refresh and is independent of the usage fetch above (renders even with no
	# credentials).
	if [ "$show_cycle" = "yes" ]; then
		parts+=("$(__claude_code_cycle_countdown)")
	fi

	local joined="" part
	for part in "${parts[@]}"; do
		if [ -z "$joined" ]; then
			joined="$part"
		else
			joined="${joined}${TMUX_POWERLINE_SEG_CLAUDE_CODE_SEPARATOR}${part}"
		fi
	done
	[ -n "$joined" ] && echo "$joined"
}

# Session/weekly windows from the usage endpoint, cached in a stat file. Echoes
# the formatted windows ("session <SEPARATOR> weekly"; either is omitted per its
# flag), or the last cached value when the token/endpoint is unavailable, or
# nothing. The cycle/billing window is handled by the callers, not here.
__claude_code_usage_windows() {
	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/claude_code_limits.stat"

	# We read the OAuth token but never refresh it; Claude Code only refreshes it
	# when it runs. So after a long idle the token can be expired (-> 401, a bail
	# path below) and the cached value sticks until Claude Code next launches --
	# that, not UPDATE_INTERVAL, is why a stale value can persist for minutes.
	if ! tp_is_tmp_valid "$tmp_file" "$TMUX_POWERLINE_SEG_CLAUDE_CODE_UPDATE_INTERVAL"; then
		local token
		token="$(jq -r '.claudeAiOauth.accessToken // empty' "$TMUX_POWERLINE_SEG_CLAUDE_CODE_CREDENTIALS_FILE" 2>/dev/null)"
		if [ -z "$token" ]; then
			# No credentials; keep any previously cached value rather than clobbering it.
			[ -f "$tmp_file" ] && cat "$tmp_file"
			return 0
		fi

		# These are Claude Code's own private OAuth endpoints; the live quota
		# state exists only server-side, so we reuse Claude Code's OAuth token
		# to read it. Three request headers are involved:
		#   anthropic-version: required on every Anthropic API call. Pins the
		#     response schema (.five_hour/.seven_day/.utilization/.resets_at).
		#     Valid values are listed under "Version history" at
		#     https://platform.claude.com/docs/en/api/versioning -- if
		#     2023-06-01 is ever retired, bump to the newest date there.
		#   anthropic-beta: opts these /api/oauth/* endpoints into accepting an
		#     OAuth bearer token instead of an API key. Undocumented and may
		#     rotate; recover the current value from what Claude Code itself
		#     sends, e.g. by grepping its installed bundle (GNU-only: `readlink
		#     -f` has no macOS/BSD equivalent, so resolve the symlink by hand there):
		#       grep -rhoE 'oauth-[0-9]{4}-[0-9]{2}-[0-9]{2}' "$(dirname "$(readlink -f "$(command -v claude)")")"
		#   User-Agent: cosmetic client identification, not required.
		# A rejected pin returns 4xx; the check below then keeps the cached
		# value, so a frozen bar is the tell-tale of a stale version/beta.
		local usage
		usage="$(curl -s --max-time 5 --url "$TMUX_POWERLINE_SEG_CLAUDE_CODE_API_URL" \
			--header "Authorization: Bearer ${token}" \
			--header "anthropic-version: 2023-06-01" \
			--header "anthropic-beta: oauth-2025-04-20" \
			--header "User-Agent: tmux-powerline")"

		# Bail (keep cache) if the response is not the expected shape, e.g. on
		# a 401 from an expired token or a transient error.
		if ! echo "$usage" | jq -e '.five_hour' >/dev/null 2>&1; then
			[ -f "$tmp_file" ] && cat "$tmp_file"
			return 0
		fi

		# Build one token per window, joining each percentage to its own time-left
		# with TIME_JOINER, so "10% 3:48" stays together; windows are joined with
		# the looser SEPARATOR below.
		local parts=() group joiner="$TMUX_POWERLINE_SEG_CLAUDE_CODE_TIME_JOINER"

		# Session window: percentage and 5-hour time-left.
		group=""
		if tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_SESSION"; then
			group="$(echo "$usage" | jq -r '"\(.five_hour.utilization // 0 | floor)%"')"
		fi
		if tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_SESSION_TIME"; then
			local session_seconds session_time
			session_seconds="$(tp_seconds_until_iso8601 "$(echo "$usage" | jq -r '.five_hour.resets_at // empty')")"
			session_time="${TMUX_POWERLINE_SEG_CLAUDE_CODE_SESSION_TIME_SYMBOL}$(tp_seconds_to_hm "$session_seconds")"
			[ -n "$group" ] && group="${group}${joiner}${session_time}" || group="$session_time"
		fi
		[ -n "$group" ] && parts+=("$group")

		# Weekly window: percentage and 7-day time-left.
		group=""
		if tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_WEEKLY"; then
			group="$(echo "$usage" | jq -r '"\(.seven_day.utilization // 0 | floor)%"')"
		fi
		if tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_WEEKLY_TIME"; then
			local weekly_seconds weekly_time
			weekly_seconds="$(tp_seconds_until_iso8601 "$(echo "$usage" | jq -r '.seven_day.resets_at // empty')")"
			weekly_time="${TMUX_POWERLINE_SEG_CLAUDE_CODE_WEEKLY_TIME_SYMBOL}$(tp_seconds_to_dh "$weekly_seconds")"
			[ -n "$group" ] && group="${group}${joiner}${weekly_time}" || group="$weekly_time"
		fi
		[ -n "$group" ] && parts+=("$group")

		local joined="" part
		for part in "${parts[@]}"; do
			if [ -z "$joined" ]; then
				joined="$part"
			else
				joined="${joined}${TMUX_POWERLINE_SEG_CLAUDE_CODE_SEPARATOR}${part}"
			fi
		done

		echo "$joined" >"$tmp_file"
	fi

	cat "$tmp_file"
}

__claude_code_cost() {
	if ! tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_COST"; then
		return 0
	fi

	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/claude_code_cost.stat"

	# ccusage is heavy, so the dollar figures are cached for COST_UPDATE_INTERVAL.
	# The cycle countdown, by contrast, is local and cheap and must stay current,
	# so it is NOT baked into the cache: the cached string carries a placeholder
	# where the countdown belongs, and __claude_code_render_cost substitutes the
	# live value in on every render. The placeholder is emitted unconditionally
	# (regardless of SHOW_CYCLE_TIME) so toggling that flag takes effect at once,
	# without waiting for the cache to expire.
	if ! tp_is_tmp_valid "$tmp_file" "$TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_UPDATE_INTERVAL"; then
		local mode="$TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_MODE"
		local ph="%%TPCC_CYCLE%%"

		local output="" alltime_cost period_cost alltime_fmt period_fmt
		case "$mode" in
		period)
			period_cost="$(__claude_code_ccusage_cost "$(__claude_code_period_start)")" || { [ -f "$tmp_file" ] && __claude_code_render_cost "$tmp_file"; return 0; }
			# shellcheck disable=SC2059
			period_fmt="$(LC_ALL=C printf "$TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_FORMAT" "$period_cost")"
			output="${period_fmt}${ph}"
			;;
		both)
			alltime_cost="$(__claude_code_ccusage_cost "")" || { [ -f "$tmp_file" ] && __claude_code_render_cost "$tmp_file"; return 0; }
			period_cost="$(__claude_code_ccusage_cost "$(__claude_code_period_start)")" || { [ -f "$tmp_file" ] && __claude_code_render_cost "$tmp_file"; return 0; }
			# shellcheck disable=SC2059
			alltime_fmt="$(LC_ALL=C printf "$TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_FORMAT" "$alltime_cost")"
			# shellcheck disable=SC2059
			period_fmt="$(LC_ALL=C printf "$TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_FORMAT" "$period_cost")"
			# Period figure parenthesised since it trails the all-time figure; the
			# cycle placeholder rides inside the parens, next to the period figure.
			output="${alltime_fmt} (${period_fmt}${ph})"
			;;
		*) # alltime
			alltime_cost="$(__claude_code_ccusage_cost "")" || { [ -f "$tmp_file" ] && __claude_code_render_cost "$tmp_file"; return 0; }
			# shellcheck disable=SC2059
			alltime_fmt="$(LC_ALL=C printf "$TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_FORMAT" "$alltime_cost")"
			output="${alltime_fmt}${ph}"
			;;
		esac

		echo "${output}" >"$tmp_file"
	fi

	__claude_code_render_cost "$tmp_file"
}

# Emit the cached cost string ($1), substituting the live cycle countdown for its
# placeholder. Computing the countdown here (not when the cost cache is written)
# keeps it current between the heavier ccusage refreshes. The placeholder stands
# for the whole "<joiner><marker><countdown>" chunk, so it collapses to nothing
# when SHOW_CYCLE_TIME is off -- the join spacing lives with the countdown, not
# the cost. A pre-placeholder cache (older version) simply has nothing to swap.
__claude_code_render_cost() {
	local template cycle=""
	template="$(cat "$1" 2>/dev/null)"
	if tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_SHOW_CYCLE_TIME"; then
		cycle="${TMUX_POWERLINE_SEG_CLAUDE_CODE_TIME_JOINER}$(__claude_code_cycle_countdown)"
	fi
	echo "${template//%%TPCC_CYCLE%%/${cycle}}"
}

# The cycle countdown as its own token: the cycle marker followed by the
# days/hours until the next renewal (e.g. "↻5d12h"). Rendered standalone in slot
# 3 when cost is off, appended to the cost figure (with TIME_JOINER) when cost is
# on, and used as the cold-start fallback in run_segment.
__claude_code_cycle_countdown() {
	echo "${TMUX_POWERLINE_SEG_CLAUDE_CODE_CYCLE_TIME_SYMBOL}$(tp_seconds_to_dh "$(__claude_code_cycle_seconds)")"
}

# Run ccusage scoped to Claude Code only and echo .totals.totalCost. $1 is an
# optional "since" date (YYYY-MM-DD); empty means all time. Returns non-zero if
# ccusage produced no usable total (so the caller can keep the cached value).
__claude_code_ccusage_cost() {
	local since="$1" json total
	# CCUSAGE_CMD may itself be several words (e.g. "nix run .../ccusage --").
	# Whitespace-split it into an argv array with read -a and append flags as
	# elements; the later "${cmd[@]}" / "${args[@]}" then expand quoted, so no
	# globbing occurs. Splitting is on IFS whitespace only -- an individual
	# argument cannot contain spaces, which is fine for a command name or the
	# documented "nix run ... --" form (it is not a full shell-quote parse).
	local -a cmd args=(claude daily)
	read -r -a cmd <<<"$TMUX_POWERLINE_SEG_CLAUDE_CODE_CCUSAGE_CMD"
	# Bail on an empty/blank CCUSAGE_CMD: an empty cmd array would make
	# "${cmd[@]}" "${args[@]}" collapse to running `claude daily ...` (the args
	# alone), i.e. invoke the real `claude` CLI instead of ccusage. Returning
	# non-zero here keeps the cached value, same as any other ccusage failure.
	[ "${#cmd[@]}" -eq 0 ] && return 1
	tp_is_flag_enabled "$TMUX_POWERLINE_SEG_CLAUDE_CODE_CCUSAGE_OFFLINE" && args+=(--offline)
	[ -n "$since" ] && args+=(--since "$since")
	args+=(--json)

	json="$("${cmd[@]}" "${args[@]}" 2>/dev/null)"
	total="$(echo "$json" | jq -r '.totals.totalCost // empty' 2>/dev/null)"
	[ -z "$total" ] && return 1
	echo "$total"
}

# Start date (YYYY-MM-DD) of the current payment period: the most recent
# occurrence of the renewal day on or before today.
__claude_code_period_start() {
	local day year month today_day
	day="$(__claude_code_renewal_day)"
	year="$(date +%Y)"
	month="$((10#$(date +%m)))"
	today_day="$((10#$(date +%d)))"
	# Not reached the renewal day yet this month? Then the period started on that
	# day last month. Stepped back with plain arithmetic so no GNU-only
	# `date -d`/BSD-only `date -v` month math is needed.
	if [ "$today_day" -lt "$day" ]; then
		month=$((month - 1))
		if [ "$month" -lt 1 ]; then
			month=12
			year=$((year - 1))
		fi
	fi
	printf '%04d-%02d-%02d\n' "$year" "$month" "$day"
}

# Resolve the renewal day-of-month (1-28). COST_PERIOD_START_DAY is either a
# number or "auto"; "auto" derives it from the subscription billing anchor
# (organization.subscription_created_at, falling back to account.created_at) and
# caches it for a week. Note this anchor is the original signup date and does not
# track later plan changes (see COST_PERIOD_START_DAY above). If the API is
# unreachable, the fallback day is used.
__claude_code_renewal_day() {
	local configured_day="$TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_PERIOD_START_DAY"
	if [ "$configured_day" != "auto" ]; then
		__claude_code_clamp_day "$configured_day"
		return 0
	fi

	local cache_file="${TMUX_POWERLINE_DIR_TEMPORARY}/claude_code_renewday.stat"
	if tp_is_tmp_valid "$cache_file" 604800; then
		local cached
		cached="$(cat "$cache_file" 2>/dev/null)"
		# Only trust a well-formed cached day; a truncated/corrupt cache would
		# otherwise return an empty value and break the caller's arithmetic. On a
		# bad cache, fall through and recompute (which rewrites the cache).
		if [[ "$cached" =~ ^[0-9]+$ ]]; then
			__claude_code_clamp_day "$cached"
			return 0
		fi
	fi

	local token profile day
	token="$(jq -r '.claudeAiOauth.accessToken // empty' "$TMUX_POWERLINE_SEG_CLAUDE_CODE_CREDENTIALS_FILE" 2>/dev/null)"
	if [ -n "$token" ]; then
		# Same three headers as __claude_code_usage_windows -- see there for what
		# each does and how to refresh the pinned anthropic-version / anthropic-beta.
		profile="$(curl -s --max-time 5 --url "$TMUX_POWERLINE_SEG_CLAUDE_CODE_PROFILE_URL" \
			--header "Authorization: Bearer ${token}" \
			--header "anthropic-version: 2023-06-01" \
			--header "anthropic-beta: oauth-2025-04-20" \
			--header "User-Agent: tmux-powerline")"
		# Day-of-month is characters 9-10 of the ISO 8601 timestamp; avoids any
		# locale/date parsing of the fractional-second value.
		day="$(echo "$profile" | jq -r '((.organization.subscription_created_at // .account.created_at) // "")[8:10]' 2>/dev/null)"
		if [[ "$day" =~ ^[0-9]{2}$ ]]; then
			day="$(__claude_code_clamp_day "$((10#$day))")"
			echo "$day" >"$cache_file"
			echo "$day"
			return 0
		fi
	fi

	# API unreachable / unexpected shape: use the fallback, and do not cache so it
	# is retried on the next refresh.
	__claude_code_clamp_day "$TMUX_POWERLINE_SEG_CLAUDE_CODE_COST_PERIOD_START_FALLBACK_DAY"
}

# Constrain a day-of-month to 1-28 so the computed --since date is always valid.
__claude_code_clamp_day() {
	local day="$1"
	[[ "$day" =~ ^[0-9]+$ ]] || day=1
	[ "$day" -lt 1 ] && day=1
	[ "$day" -gt 28 ] && day=28
	echo "$day"
}

# Seconds until the next renewal (current period start + 1 month), clamped >= 0.
# Anchored to UTC midnight of the renewal day: the civil day count (see
# tp_days_from_civil) times 86400 is that day's UTC epoch, and
# `date +%s` is also a UTC epoch, so the subtraction is exact -- no local time
# enters, hence no DST edge cases -- and it needs no GNU/BSD-specific date math.
# (The renewal's true time-of-day is unknown anyway; only the day-of-month is
# derived from the billing anchor, so UTC midnight is as good a mark as any.)
__claude_code_cycle_seconds() {
	local period_start year month day remaining
	period_start="$(__claude_code_period_start)" # YYYY-MM-DD
	year="$((10#${period_start:0:4}))"
	month="$((10#${period_start:5:2}))"
	day="$((10#${period_start:8:2}))"
	# The renewal is one month after the period start (day stays 1-28, always
	# valid). Roll the year over at December.
	month=$((month + 1))
	if [ "$month" -gt 12 ]; then
		month=1
		year=$((year + 1))
	fi
	remaining=$(($(tp_days_from_civil "$year" "$month" "$day") * 86400 - $(date +%s)))
	[ "$remaining" -lt 0 ] && remaining=0
	echo "$remaining"
}
