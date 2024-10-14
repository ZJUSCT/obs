#!/bin/bash

OTEL_BEARER_TOKEN="1" otelcol-contrib validate --config=./test.yaml

if [ $? -eq 0 ]
then
    echo "Config file is valid"
else
    echo "Config file is invalid"
    exit
fi

otelcol-contrib --config=./test.yaml
