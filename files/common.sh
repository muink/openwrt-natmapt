#!/bin/sh
# Copyright (C) 2023 muink https://github.com/muink
#
# depends jsonfilter

# JSON_EXPORT <json>
JSON_EXPORT() {
	for k in $ALL_PARAMS; do
		jsonfilter -qs "$1" -e "$k=@['$k']"
	done
}
