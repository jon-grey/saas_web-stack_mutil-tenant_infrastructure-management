#!/bin/bash
set -euo pipefail

echo "
###########################################################################
#### Create service principal used in terraform and save to $RBAC_JSON
###########################################################################"

# uncomment at first run
# az login 

az account set --subscription $AZURE_SUBSCRIPTION_ID

# Generate Azure client id and secret for terraform.


if test -f "$RBAC_JSON"; then
	RBAC="$(cat $RBAC_JSON)"
else
    RBAC_NAME="--name $AZURE_SERVICE_PRINCIPAL"
    RBAC_ROLE="--role Contributor"
    RBAC_SCOPES="--scopes /subscriptions/${AZURE_SUBSCRIPTION_ID}"
	RBAC=$(az ad sp create-for-rbac $RBAC_NAME $RBAC_ROLE $RBAC_SCOPES)
	echo $RBAC > $RBAC_JSON
fi

ARM_TENANT_ID=$(rdict     "${RBAC}" "tenant")
ARM_CLIENT_ID=$(rdict     "${RBAC}" "appId")
ARM_CLIENT_SECRET=$(rdict "${RBAC}" "password")

echo "
Store SECRETS below as [github secrets](https://github.com/jon-grey/github-actions_terraform_deploy_to_azure/settings/secrets/actions)
======================================================
ARM_TENANT_ID = $ARM_TENANT_ID
ARM_CLIENT_ID = $ARM_CLIENT_ID
ARM_CLIENT_SECRET = $ARM_CLIENT_SECRET
AZURE_SUBSCRIPTION_ID = $AZURE_SUBSCRIPTION_ID
======================================================"

while true; do
    read -p "Done updating secrets?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) continue;;
        * ) echo "Please answer yes or no.";;
    esac
done

echo "
###########################################################################
#### Create service principal used in github actions az cli and save to $RBAC_SDK_JSON
###########################################################################"


# Generate Azure client id and secret for github actions az cli.

if test -f "$RBAC_SDK_JSON"; then
	RBAC="$(cat $RBAC_SDK_JSON)"
else
    RBAC_NAME="--name $AZURE_SERVICE_PRINCIPAL_SDK"
    RBAC_ROLE="--role Contributor"
    RBAC_SCOPES="--scopes /subscriptions/${AZURE_SUBSCRIPTION_ID}"
	RBAC=$(az ad sp create-for-rbac --sdk-auth $RBAC_NAME $RBAC_ROLE $RBAC_SCOPES)
	echo $RBAC > $RBAC_SDK_JSON
fi

echo "Store json below as AZURE_CREDENTIALS in github secrets"
echo "======================================================"
cat $RBAC_SDK_JSON 
echo "======================================================"

while true; do
    read -p "Done updating secrets?" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) continue;;
        * ) echo "Please answer yes or no.";;
    esac
done