TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL="${TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL:-󱃾}"
TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL_COLOUR:-255}"


generate_segmentrc() {
	read -d '' rccontents << EORC
# Kubernetes config context symbol.
# export TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL="${TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL}"
# Kubernetes config context symbol colour.
# export TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL_COLOUR}"
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	type kubectl >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		return 0
	fi
	kubernetes_context=$(kubectl config current-context)
	echo -n "#[${TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL_COLOUR}]${TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL} #[fg=${TMUX_POWERLINE_CUR_SEGMENT_FG}]${kubernetes_context}"
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL" ]; then
		export TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL="${TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL_COLOUR" ]; then
		export TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL_COLOUR="${TMUX_POWERLINE_SEG_KUBERNETES_CONTEXT_SYMBOL_COLOUR}"
	fi
}
