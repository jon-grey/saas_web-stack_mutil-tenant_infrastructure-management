#!/bin/bash
set -euo pipefail

export TF_WARN_OUTPUT_ERRORS=1

echo "
###########################################################################
#### Apply TF AZ AKS
###########################################################################"

az account set --subscription $AZURE_SUBSCRIPTION_ID

(
    cd ../deployments/terraform/azure-ops

    cowsay "Format terraform files $PWD..."
    terraform fmt
    echo "... with RC ==> $?"

    cowsay "Init terraform $PWD..."
    terraform init -upgrade
    echo "... with RC ==> $?"

    cowsay "Validate terraform confif files $PWD..."
    terraform validate
    echo "... with RC ==> $?"

    cowsay "Plan terraform $PWD..."
    terraform plan
    echo "... with RC ==> $?"

    cowsay "Apply terraform $PWD..."
    terraform apply -auto-approve
    echo "... with RC ==> $?"

)
