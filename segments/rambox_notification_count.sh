# Report Rambox notification counts (from injected Javascript code)

TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_PORT_DEFAULT="48321"
TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_CHAR_DEFAULT=""

generate_segmentrc() {
	read -d '' rccontents  << EORC
# The port the Python server will be run on that is delivered with this segment; simply choose a free port
# (the default should be ok) and use this port in the Rambox Javascript injection
export TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_PORT="${TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_PORT_DEFAULT}"
# Notification symbol
export TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_CHAR="${TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_CHAR_DEFAULT}"
EORC
	echo "${rccontents}"
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_PORT" ]; then
        export TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_PORT="${TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_PORT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_CHAR" ]; then
		export TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_CHAR="${TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_CHAR_DEFAULT}"
	fi
}

run_segment() {
	__process_settings

	local count

	count="$( curl "http://localhost:${TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_PORT}" )"
	if [[ "$?" -eq 7 ]]; then
		nohup python3 - <<-EOF >/dev/null 2>&1 &
			import re
			from http.server import HTTPServer, BaseHTTPRequestHandler
			from urllib.parse import parse_qs


			PORT = ${TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_PORT}


			class CorsRequestHandler(BaseHTTPRequestHandler):
			    def end_headers(self):
			        self.send_header("Access-Control-Allow-Origin", "*")
			        super().end_headers()


			class CountRequestHandler(CorsRequestHandler):
			    _counts = {}

			    def do_GET(self):
			        cls = self.__class__
			        if cls._counts:
			            self.send_response(200)
			            self.end_headers()
			            if any(count == "true" for count in self._counts.values()):
			                sum_of_counts = "true"
			            else:
			                sum_of_counts = sum(self._counts.values())
			            self.wfile.write("{}".format(sum_of_counts).encode())
			        else:
			            self.send_response(404)
			            self.end_headers()

			    def do_POST(self):
			        cls = self.__class__
			        content_length = int(self.headers["Content-Length"])
			        post_vars = {
			            k.decode(): v[0].decode() for k, v in parse_qs(self.rfile.read(content_length), keep_blank_values=1).items()
			        }
			        counts_were_empty = not bool(cls._counts)
			        matched_any = False
			        for key, value in post_vars.items():
			            match = re.match(r"^count\d*$", key)
			            if match:
			                matched_any = True
			                count_key = match.group(0)
			                count = post_vars[count_key]
			                if count.lower() == "true":
			                    cls._counts[count_key] = "true"
			                else:
			                    try:
			                        cls._counts[count_key] = int(count)
			                    except ValueError:
			                        cls._counts[count_key] = 0
			        if matched_any:
			            self.send_response(201 if counts_were_empty else 204)
			        else:
			            self.send_response(500)
			        self.end_headers()


			def main():
			    server_address = ("localhost", PORT)
			    httpd = HTTPServer(server_address, CountRequestHandler)
			    httpd.serve_forever()


			if __name__ == "__main__":
			    main()
		EOF
		count="$( curl "http://localhost:${TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_PORT}" )"
    fi

	if [[ -n "${count}" ]]; then
		if [[ "${count}" == "true" ]]; then
			echo "${TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_CHAR}"
		elif [[ "${count}" -gt 0 ]]; then
			echo "${TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_CHAR} ${count}"
		fi
		return 0
	fi

	return 1
}
