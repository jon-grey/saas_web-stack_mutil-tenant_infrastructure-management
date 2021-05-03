#!/bin/bash
set -euo pipefail

. ../exports.sh
. ../exports-private.sh

mkdir -p .files

cowsay "separate blob for ops"
export LOCAL_BLOB_FILE=".files/storage-blob-random-suffix-ops"

if ! test -f "$LOCAL_BLOB_FILE"; then 
    echo $(random) > $LOCAL_BLOB_FILE
fi

export BLOB_NUMBER=$(cat $LOCAL_BLOB_FILE)
export AZURE_STORAGE_BLOB_TFSTATE_LOCAL_OPS=az-terraform-state-${BLOB_NUMBER}

cowsay "separate blob for aks"
export LOCAL_BLOB_FILE=".files/storage-blob-random-suffix-aks"

if ! test -f "$LOCAL_BLOB_FILE"; then 
    echo $(random) > $LOCAL_BLOB_FILE
fi

export BLOB_NUMBER=$(cat $LOCAL_BLOB_FILE)
export AZURE_STORAGE_BLOB_TFSTATE_LOCAL_AKS=az-terraform-state-${BLOB_NUMBER}


export KUBECONFIG=~/.kube/aksconfig

az account set --subscription $AZURE_SUBSCRIPTION_ID
az aks get-credentials \
	--resource-group $AZURE_RESOURCE_GROUP_DEVS \
	--name $AZURE_AKS_CLUSTER_NAME || true

echo "
###########################################################################
#### Test infrastructure management deployments setup
###########################################################################"

bash 02.make.terraform.tfvars.sh
bash 02.setup.azure.storage-account.sh
bash 03.setup.azure.blob.terraform-tfstate.sh
# bash 03.test.local.docker-compose.sh
# bash 03.test.local.terraform.ops.sh
# bash 03.test.local.terraform.aks.sh
# bash 04.apply.local.terraform.ops.sh
bash 04.apply.local.terraform.aks.sh

git add --all
git commit -m "Lazy update at $(date)."
git push --set-upstream origin $(git rev-parse --abbrev-ref HEAD)