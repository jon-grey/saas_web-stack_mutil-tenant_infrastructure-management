#!/bin/bash
set -euo pipefail


az account set --subscription $AZURE_SUBSCRIPTION_ID

echo "
###########################################################################
#### Setup Terraform on Azure
###########################################################################"

cowsay "Create az group for ops"
az group show -g ${AZURE_RESOURCE_GROUP_OPS} \
|| az group create -g ${AZURE_RESOURCE_GROUP_OPS} -l ${AZURE_LOCATION}

cowsay "Create storage account for ops"
az storage account show -n ${AZURE_STORAGE_ACCOUNT_OPS} \
|| az storage account create -n ${AZURE_STORAGE_ACCOUNT_OPS} -g ${AZURE_RESOURCE_GROUP_OPS} -l ${AZURE_LOCATION} --sku Standard_LRS


