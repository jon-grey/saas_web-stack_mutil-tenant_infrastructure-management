#!/bin/bash
set -euo pipefail

. exports-functions.sh || . ../exports-functions.sh

export HOME_AZ_DIR="$HOME/.az/.files"
export RBAC_JSON="$HOME_AZ_DIR/rbac.json"
export RBAC_SDK_JSON="$HOME_AZ_DIR/rbac-sdk.json"
export STORAGE_ACC_SUFFIX_FILE="$HOME_AZ_DIR/storage-acc-random-suffix"
export WORKSPACES=( "devs" "prod" "stag" "test" )
export TF_LOG="ERROR"

mkdir -p $HOME_AZ_DIR

if ! test -f "$STORAGE_ACC_SUFFIX_FILE"; then 
    echo $(random) > $STORAGE_ACC_SUFFIX_FILE
fi

STORAGE_ACC_SUFFIX=$(cat $STORAGE_ACC_SUFFIX_FILE)


