#!/bin/bash
set -e

# source and export environment variables
source .env.template
# here we need word splitting, so we disable the warning
# shellcheck disable=SC2046
export $(cut -d= -f1 .env.template)

set -x

# validate otelcol config
otelcol-contrib validate --config ./config/otelcol/agent.yaml
otelcol-contrib validate --config ./config/otelcol/gateway.yaml
otelcol-contrib validate --config ./config/otelcol/snmp.yaml

# validate compose file
docker compose config > /dev/null

echo "Validation successful"
