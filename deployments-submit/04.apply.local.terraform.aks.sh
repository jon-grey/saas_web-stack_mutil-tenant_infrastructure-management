#!/bin/bash
set -euo pipefail

function callback ()
{
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
}

terraform_deploy "azure-aks" "ERROR" callback

