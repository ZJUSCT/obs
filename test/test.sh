#!/bin/bash

OTEL_BEARER_TOKEN="1" otelcol-contrib validate --config=./test.yaml

if [ $? -eq 0 ]
then
    echo "Config file is valid"
else
    echo "Config file is invalid"
    exit
fi

bw_login() {
    if ! command -v bw &> /dev/null
    then
        echo "bw could not be found, please install it"
        exit
    fi
    if [ -z "$BW_SESSION" ]
    then
        echo "BW_SESSION is not set, please login to bitwarden"
        # check if logged in, if success, then logout and login again
        bw login --check
        if [ $? -eq 0 ]
        then
            bw logout
        fi
        export BW_SESSION=$(bw login --raw)
    else
        # check if BW_SESSION is still valid
        bw unlock --check
        if [ $? -ne 0 ]
        then
            echo "BW_SESSION is not valid, please login to bitwarden"
            export BW_SESSION=$(bw login --raw)
        fi
    fi
    bw login --check
    if [ $? -ne 0 ]
    then
        echo "bw login failed, exit"
        exit
    fi
}

bw_login

OTEL_BEARER_TOKEN=$(bw get password "OTEL_BEARER_TOKEN") otelcol-contrib --config=./test.yaml

#bw logout
echo "remember to logout"