#!/bin/bash

alias curl="curl --retry-all-errors --retry 5 --silent --show-error --location"
alias wget="wget --tries=5 --quiet"
alias apt-get="apt-get -qq -o=Dpkg::Use-Pty=0"

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi

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
	# https://ghp.ci/
	install_deb_from_url https://ghp.ci/"$url"
}

install_deb_from_github "open-telemetry/opentelemetry-collector-releases" 'endswith("linux_amd64.deb") and contains("contrib")'

source .env
if [ -z "$OTEL_BEARER_TOKEN" ]; then
	echo "OTEL_BEARER_TOKEN is not set"
	exit 1
fi
if [ -z "$OTEL_CLOUD_REGION" ]; then
	echo "OTEL_CLOUD_REGION is not set"
	exit 1
fi
if [ ! -d /etc/systemd/system/otelcol-contrib.service.d ]; then
	mkdir -p /etc/systemd/system/otelcol-contrib.service.d
fi
cp config/others/systemd-otelcol-override.conf /etc/systemd/system/otelcol-contrib.service.d/override.conf

cp config/otelcol/agent.yaml /etc/otelcol-contrib/config.yaml

systemctl daemon-reload
systemctl restart otelcol-contrib
sleep 5
systemctl status otelcol-contrib
