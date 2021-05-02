#!/bin/bash
set -euo pipefail

export TF_WARN_OUTPUT_ERRORS=1

echo "
###########################################################################
#### PLAN AZ OPS
###########################################################################"

az account set --subscription $AZURE_SUBSCRIPTION_ID

(
    cd ../deployments/terraform/azure-ops

    cowsay "Format terraform files $PWD..."
    terraform fmt
    echo "... with RC ==> $?"

    cowsay "Init terraform $PWD..."
    terraform init 
    echo "... with RC ==> $?"

    cowsay "Create backend workspaces, $PWD..."
    # TODO multiple clusters, each for different stage
    for wsp in ${WORKSPACES[@]}; do
        terraform workspace new $wsp || true
    done
    cowsay "Select backend workspace: multistage, $PWD..."
    # NOTE currently multistage cluster
    terraform workspace new multistage || true
    terraform workspace select multistage
    
    cowsay "Validate terraform confif files $PWD..."
    terraform validate
    echo "... with RC ==> $?"

    cowsay "Plan terraform $PWD..."
    terraform plan
    echo "... with RC ==> $?"
)
