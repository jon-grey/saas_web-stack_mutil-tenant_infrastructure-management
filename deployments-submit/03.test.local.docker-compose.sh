#!/bin/bash
set -euo pipefail

export TF_WARN_OUTPUT_ERRORS=1

echo "
###########################################################################
#### Create service principal and save to $HOME/rbac.json
###########################################################################"

az account set --subscription $AZURE_SUBSCRIPTION_ID

(
    cd ../deployments/docker-compose

    docker-compose up -d

    bash docker-compose.tests.sh

)


