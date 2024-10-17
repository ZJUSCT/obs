#!/bin/bash

# check if gdg is installed
if ! command -v gdg &> /dev/null
then
    echo "gdg could not be found"
    exit
fi

# # anonymous access enabled, no need to login
# source ../.env
# export GDG_CONTEXTS__ZJUSCT__PASSWORD=$GF_SECURITY_ADMIN_PASSWORD

# backup dashboards
gdg backup dashboards list --config gdg/importer.yml
gdg backup dashboards download --config gdg/importer.yml