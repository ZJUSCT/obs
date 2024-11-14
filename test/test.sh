#!/bin/bash

OTEL_BEARER_TOKEN="1" otelcol-contrib validate --config=./test.yaml

if [ $? -eq 0 ]; then
	echo "Config file is valid"
else
	echo "Config file is invalid"
	exit
fi

. ../tools/common-function.sh

bw_login

OTEL_BEARER_TOKEN=$(bw get password "OTEL_BEARER_TOKEN") otelcol-contrib --config=./test.yaml

#bw logout
echo "remember to logout"
