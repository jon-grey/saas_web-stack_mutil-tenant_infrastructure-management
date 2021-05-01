#!/bin/bash
set -euo pipefail


az account set --subscription $AZURE_SUBSCRIPTION_ID

echo "
###########################################################################
#### Setup Terraform on Azure
###########################################################################"

cowsay "#### Create storage container for terraform state - azure ops"

az storage container exists \
    --account-name ${AZURE_STORAGE_ACCOUNT_OPS} \
    --name ${AZURE_STORAGE_BLOB_TFSTATE_LOCAL_OPS} -o tsv \
| grep -qi true \
|| az storage container create \
    --account-name ${AZURE_STORAGE_ACCOUNT_OPS} \
    --name ${AZURE_STORAGE_BLOB_TFSTATE_LOCAL_OPS}

cowsay "#### Create storage container for terraform state - azure aks"

az storage container exists \
    --account-name ${AZURE_STORAGE_ACCOUNT_OPS} \
    --name ${AZURE_STORAGE_BLOB_TFSTATE_LOCAL_AKS} -o tsv \
| grep -qi true \
|| az storage container create \
    --account-name ${AZURE_STORAGE_ACCOUNT_OPS} \
    --name ${AZURE_STORAGE_BLOB_TFSTATE_LOCAL_AKS}
