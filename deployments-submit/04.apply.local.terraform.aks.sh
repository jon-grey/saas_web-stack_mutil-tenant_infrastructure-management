#!/bin/bash
set -euo pipefail

export TF_WARN_OUTPUT_ERRORS=1

echo "
###########################################################################
#### Apply TF AZ AKS
###########################################################################"

az account set --subscription $AZURE_SUBSCRIPTION_ID

(
    cd ../deployments/terraform/azure-aks

    cowsay "Format terraform files $PWD..."
    terraform fmt
    echo "... with RC ==> $?"

    cowsay "Init terraform $PWD..."
    terraform init -upgrade
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

    cowsay "Apply terraform $PWD..."
    terraform apply -auto-approve
    echo "... with RC ==> $?"

    echo "
    # ###########################################################################
    # #### Configure AKS connection in local env 
    # ###########################################################################"
    terraform output configure
    terraform output -raw kube_config > ~/.kube/aksconfig
    export KUBECONFIG=~/.kube/aksconfig

    echo "
    # ###########################################################################
    # #### Connect to AKS
    # ###########################################################################"

    az aks get-credentials \
        --resource-group $AZURE_RESOURCE_GROUP_DEVS \
        --name $AZURE_AKS_CLUSTER_NAME || true

    kubectl get nodes


)
