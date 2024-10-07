#!/bin/bash

credential_names=(
    "OTEL_BEARER_TOKEN"
    "GF_SECURITY_ADMIN_PASSWORD"
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
    password=$(bw get password $credential_name)
    echo "$credential_name=\"$password\"" >> .env
done

bw logout
