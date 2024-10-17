#!/bin/bash

source .env

# check if env is set
if [ -z "$OTEL_BEARER_TOKEN" ]; then
        echo "OTEL_BEARER_TOKEN is not set"
        exit 1
fi

# check if .d directory exists
if [ ! -d /etc/systemd/system/otelcol-contrib.service.d ]; then
        mkdir -p /etc/systemd/system/otelcol-contrib.service.d
fi

# cp config/others/systemd-otelcol-override.conf /etc/systemd/system/otelcol-contrib.service.d/override.conf
cp config/otelcol/agent.yaml /etc/otelcol-contrib/config.yaml

systemctl daemon-reload
systemctl restart otelcol-contrib
systemctl status otelcol-contrib
