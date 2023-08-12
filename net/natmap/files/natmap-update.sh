#!/bin/sh

. /usr/share/libubox/jshn.sh

(
	json_init
	json_add_string sid "$SECTIONID"
	json_add_string ip "$1"
	json_add_int port "$2"
	json_add_string ip4p "$3"
	json_add_int inner_port "$4"
	json_add_string protocol "$5"
	json_add_string inner_ip "$6"
	shift 6
	json_dump > /var/run/natmap/$PPID.json
)

[ -n "${NOTIFY_SCRIPT}" ] && {
	export -n NOTIFY_SCRIPT
	exec "${NOTIFY_SCRIPT}" "$ip" "$port" "$ip4p" "$inner_port" "$protocol" "$inner_ip" "$sid" "$@"
}
