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
			from http.server import HTTPServer, BaseHTTPRequestHandler
			from urllib.parse import parse_qs


			PORT = ${TMUX_POWERLINE_SEG_RAMBOX_NOTIFICATION_COUNT_PORT}


			class CountRequestHandler(BaseHTTPRequestHandler):
			    _count = None

			    def do_GET(self):
			        cls = self.__class__
			        if cls._count is not None:
			            self.send_response(200)
			            self.end_headers()
			            self.wfile.write("{}".format(cls._count).encode())
			        else:
			            self.send_response(404)
			            self.end_headers()

			    def do_POST(self):
			        cls = self.__class__
			        content_length = int(self.headers["Content-Length"])
			        post_vars = parse_qs(self.rfile.read(content_length), keep_blank_values=1)
			        print(post_vars)
			        if b"count" in post_vars:
			            self.send_response(201 if cls._count is None else 204)
			            self.end_headers()
			            count = post_vars[b"count"][0].decode()
			            if count.lower() == "true":
			                cls._count = "true"
			            else:
			                try:
			                    cls._count = int(count)
			                except ValueError:
			                    cls._count = 0
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
