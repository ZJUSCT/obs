#!/bin/bash
set -xe

OTELCOL_VERSION=0.113.0

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd $SCRIPT_DIR/..

if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        exit 1
fi

# check if otelcol-contrib is installed and is up to date
dpkg -l | grep otelcol-contrib > /dev/null
OTELCOL_INSTALLED=$?
dpkg -l | grep otelcol-contrib | grep $OTELCOL_VERSION > /dev/null
OTELCOL_LATEST=$?

if [ $OTELCOL_INSTALLED -ne 0 ] || [ $OTELCOL_LATEST -ne 0 ]; then
        echo "installing/upgrading otelcol-contrib $OTELCOL_VERSION"
        # https://ghp.ci/
        wget https://ghp.ci/https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v${OTELCOL_VERSION}/otelcol-contrib_${OTELCOL_VERSION}_linux_amd64.deb -O /tmp/otelcol-contrib.deb
        dpkg -i /tmp/otelcol-contrib.deb
        rm /tmp/otelcol-contrib.deb
fi

if [ $OTELCOL_INSTALLED -ne 0 ]; then
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
fi

cp config/otelcol/agent.yaml /etc/otelcol-contrib/config.yaml

systemctl daemon-reload
systemctl restart otelcol-contrib
sleep 5
systemctl status otelcol-contrib
