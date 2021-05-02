#!/bin/bash
set -euo pipefail

az account set --subscription $AZURE_SUBSCRIPTION_ID

# Generate Azure client id and secret.
if test -f "$RBAC_JSON"; then
	RBAC="$(cat $RBAC_JSON)"
else
	cowsay "[ERROR] no RBAC file"
    exit 1
fi

echo "
###########################################################################
#### Read variables from RBAC dict
###########################################################################"

ARM_TENANT_ID=$(rdict     "$RBAC" "tenant")
ARM_CLIENT_ID=$(rdict     "$RBAC" "appId")
ARM_CLIENT_SECRET=$(rdict "$RBAC" "password")

echo "
###########################################################################
#### Populate terraform variables file for ops infrastructure
###########################################################################"

TFVARS="../deployments/terraform/azure-ops/terraform.tfvars"

echo "
az_location                 = ${DQT}${AZURE_LOCATION}${DQT}
az_storage_tfstate          = ${DQT}${AZURE_STORAGE_BLOB_TFSTATE_LOCAL_OPS}${DQT}
az_storage_account_ops      = ${DQT}${AZURE_STORAGE_ACCOUNT_OPS}${DQT}
az_storage_account_devs     = ${DQT}${AZURE_STORAGE_ACCOUNT_DEVS}${DQT}
az_resource_group_name_devs = ${DQT}${AZURE_RESOURCE_GROUP_DEVS}${DQT}
az_resource_group_name_ops  = ${DQT}${AZURE_RESOURCE_GROUP_OPS}${DQT}
date                        = ${DQT}$(date)${DQT}
" > $TFVARS
cat $TFVARS

echo "
###########################################################################
#### Populate terraform variables file for devs aks infrastructure
###########################################################################"

TFVARS="../deployments/terraform/azure-aks/terraform.tfvars"

echo "
date                        = ${DQT}$(date)${DQT}

letencrypt_email            = ${DQT}${LETSENCRYPT_EMAIL}${DQT}
az_custom_domain            = ${DQT}${CUSTOM_DOMAIN}${DQT}

az_arm_client_id            = ${DQT}${ARM_CLIENT_ID}${DQT}
az_arm_client_secret        = ${DQT}${ARM_CLIENT_SECRET}${DQT}
az_location                 = ${DQT}${AZURE_LOCATION}${DQT}
az_resource_group_name      = ${DQT}${AZURE_RESOURCE_GROUP_DEVS}${DQT}
az_container_registry_name  = ${DQT}${AZURE_CONTAINER_REGISTRY}${DQT}

az_aks_dns_prefix           = ${DQT}${AZURE_AKS_DNS_PREFIX}${DQT}
az_aks_cluster_name         = ${DQT}${AZURE_AKS_CLUSTER_NAME}${DQT}
az_aks_admin_username       = ${DQT}${AZURE_AKS_NODES_ADMIN}${DQT}

" > $TFVARS
cat $TFVARS

echo "
###########################################################################
#### Populate terraform provider file
###########################################################################"

echo "

terraform {
  backend ${DQT}azurerm${DQT} {
    resource_group_name  = ${DQT}${AZURE_RESOURCE_GROUP_OPS}${DQT}
    storage_account_name = ${DQT}${AZURE_STORAGE_ACCOUNT_OPS}${DQT}
    container_name       = ${DQT}${AZURE_STORAGE_BLOB_TFSTATE_LOCAL_OPS}${DQT}
    key                  = ${DQT}terraform.tfstate${DQT}
  }
}

" > "../deployments/terraform/azure-ops/provider.tf"

echo "
###########################################################################
#### Populate terraform provider file
###########################################################################"

echo "

terraform {
  backend ${DQT}azurerm${DQT} {
    resource_group_name  = ${DQT}${AZURE_RESOURCE_GROUP_OPS}${DQT}
    storage_account_name = ${DQT}${AZURE_STORAGE_ACCOUNT_OPS}${DQT}
    container_name       = ${DQT}${AZURE_STORAGE_BLOB_TFSTATE_LOCAL_AKS}${DQT}
    key                  = ${DQT}terraform.tfstate${DQT}
  }
}

" > "../deployments/terraform/azure-aks/provider.tf"


echo "
###########################################################################
#### Populate .github/workflows env vars
###########################################################################"

for fp in ../.github/workflows/*.ops.yml; do

  sed \
    -i "s/AZURE_STORAGE_BLOB_TFSTATE:\s.*/AZURE_STORAGE_BLOB_TFSTATE: ${AZURE_STORAGE_BLOB_TFSTATE_LOCAL_OPS}/" \
    $fp

  sed \
    -i "s/AZURE_STORAGE_ACCOUNT_OPS:\s.*/AZURE_STORAGE_ACCOUNT_OPS: ${AZURE_STORAGE_ACCOUNT_OPS}/" \
    $fp

done


for fp in ../.github/workflows/*.aks.yml; do

  sed \
    -i "s/AZURE_STORAGE_BLOB_TFSTATE:\s.*/AZURE_STORAGE_BLOB_TFSTATE: ${AZURE_STORAGE_BLOB_TFSTATE_LOCAL_AKS}/" \
    $fp

  sed \
    -i "s/AZURE_STORAGE_ACCOUNT_OPS:\s.*/AZURE_STORAGE_ACCOUNT_OPS: ${AZURE_STORAGE_ACCOUNT_OPS}/" \
    $fp

done

