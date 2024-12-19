#!/bin/bash

# curl https://gh-proxy.com/https://raw.githubusercontent.com/ZJUSCT/clusters.zju.edu.cn/refs/heads/main/tools/upgrade_agent.sh | sudo bash

install_deb_from_url() {
	url=$1
	tmpfile=$(mktemp).deb
	if ! wget -O "$tmpfile" "$url"; then
		echo "Failed to download $url"
		exit 1
	fi
	dpkg -i "$tmpfile" >/dev/null || apt-get -f install
	rm "$tmpfile"
}

# https://gist.github.com/steinwaywhw/a4cd19cda655b8249d908261a62687f8
install_deb_from_github() {
	repo=$1
	match=$2
	url=$(curl "https://api.github.com/repos/$repo/releases/latest" | jq -r ".assets[] | select(.name|$match) | .browser_download_url")
	# https://gh-proxy.com/
	install_deb_from_url https://gh-proxy.com/"$url"
}

install_deb_from_github "open-telemetry/opentelemetry-collector-releases" 'endswith("linux_amd64.deb") and contains("contrib")'
