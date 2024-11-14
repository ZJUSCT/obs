#!/bin/bash

bw_login() {
	if ! command -v bw &>/dev/null; then
		echo "bw could not be found, please install it"
		exit 1
	fi

	if [ -z "$BW_SESSION" ] || ! bw unlock --check &>/dev/null; then
		echo "Logging into Bitwarden..."
		BW_SESSION=$(bw login --raw)
		if [ $? -ne 0 ]; then
			echo "bw login failed, exit"
			exit 1
		fi
		export BW_SESSION
	fi
}
