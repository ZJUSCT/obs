#!/bin/bash

credential_names=(
    "OTEL_BEARER_TOKEN"
    "GF_SECURITY_ADMIN_PASSWORD"
    "GF_TG_BOT_TOKEN"
    "GF_TG_CHAT_ID"
    "INFLUXDB_PASSWORD"
    "INFLUXDB_TOKEN"
    "SNMP_PRIVATE_KEY"
    "SNMP_AUTH_KEY"
)

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

# create .env file
if [ -f .env ]
then
    rm .env
fi

# for each credential name, get the password, append it to .env using format CREDENTIAL_NAME=PASSWORD
for credential_name in "${credential_names[@]}"
do
    echo "Getting $credential_name"
    password=$(bw get password $credential_name)
    if [ -z "$password" ]
    then
        echo "Failed to get $credential_name"
        continue
    fi
    echo "$credential_name=\"$password\"" >> ../.env
done

bw logout
