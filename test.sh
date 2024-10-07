#!/bin/bash

# test otel-collector
echo -n 'otel-collector '
curl -s 'http://localhost:13134/'

# test clickhouse
echo -n 'clickhouse '
echo 'SELECT version()' | curl 'http://localhost:8123/' --data-binary @-

# test prometheus
echo -n 'prometheus '
curl -s 'http://localhost:9090/api/v1/query?query=up' | jq '.status'

# test grafana
echo -n 'grafana '
curl -s 'http://localhost:3000/api/health' | jq '.database'

