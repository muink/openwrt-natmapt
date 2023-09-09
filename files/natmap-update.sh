#!/bin/bash
ip="$1"
port="$2"
ip4p="$3"
inner_port="$4"
protocol="$5"
inner_ip="$6"
shift 6

. /usr/share/libubox/jshn.sh
INITD='/etc/init.d/natmap'

if [ -n "$RWFW" -a "$($INITD info|jsonfilter -qe "@['$(basename $INITD)'].instances['$SECTIONID'].data.firewall[0].dest_port")" != "$port" ]; then
	export PUBPORT="$port" #PROCD_DEBUG=1
	$INITD start "$SECTIONID"
fi
if [ -n "$REFRESH" ]; then
	json_cleanup
	json_load "$REFRESH_PARAM"
	json_add_int port "$port"
	$REFRESH "$(json_dump)"
fi
if [ -n "$NOTIFY" ]; then
	comment="$(jsonfilter -qs "$NOTIFY_PARAM" -e '@["comment"]')"
	_text="$(jsonfilter -qs "$NOTIFY_PARAM" -e '@["text"]')"
	[ -z "$_text" ] && _text="NATMap: ${comment:+$comment: }[${protocol^^}] $inner_ip:$inner_port -> $ip:$port" \
	|| _text="$(echo "$_text" | sed " \
		s|<comment>|$comment|g; \
		s|<protocol>|$protocol|g; \
		s|<inner_ip>|$inner_ip|g; \
		s|<inner_port>|$inner_port|g; \
		s|<ip>|$ip|g; \
		s|<port>|$port|g")"
	json_cleanup
	json_load "$NOTIFY_PARAM"
	json_add_string text "$_text"
	$NOTIFY "$(json_dump)"
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

[ -n "${CUSTOM_SCRIPT}" ] && {
	export -n CUSTOM_SCRIPT
	exec "${CUSTOM_SCRIPT}" "$ip" "$port" "$ip4p" "$inner_port" "$protocol" "$inner_ip" "$SECTIONID" "$@"
}
