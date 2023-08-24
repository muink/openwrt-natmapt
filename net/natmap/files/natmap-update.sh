#!/bin/sh
ip="$1"
port="$2"
ip4p="$3"
inner_port="$4"
protocol="$5"
inner_ip="$6"
shift 6

. /usr/share/libubox/jshn.sh
INITD='/etc/init.d/natmap'

if [ -n "$REFRESH" -a "$($INITD info|jsonfilter -qe "@['$(basename $INITD)'].instances['$SECTIONID'].data.firewall[0].dest_port")" != "$port" ]; then
	export PUBPORT="$port" #PROCD_DEBUG=1
	$INITD start "$SECTIONID"
fi

(
	json_init
	json_add_string sid "$SECTIONID"
	json_add_string ip "$ip"
	json_add_int port "$port"
	json_add_string ip4p "$ip4p"
	json_add_int inner_port "$inner_port"
	json_add_string protocol "$protocol"
	json_add_string inner_ip "$inner_ip"
	json_dump > /var/run/natmap/$PPID.json
)

[ -n "${NOTIFY_SCRIPT}" ] && {
	export -n NOTIFY_SCRIPT
	exec "${NOTIFY_SCRIPT}" "$ip" "$port" "$ip4p" "$inner_port" "$protocol" "$inner_ip" "$SECTIONID" "$@"
}
