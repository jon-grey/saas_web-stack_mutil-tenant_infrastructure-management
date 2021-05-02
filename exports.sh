#!/bin/bash
set -euo pipefail

export DQT='"'
export HOME_AZ_DIR="$HOME/.az/.files"
export RBAC_JSON="$HOME_AZ_DIR/rbac.json"
export RBAC_SDK_JSON="$HOME_AZ_DIR/rbac-sdk.json"
export STORAGE_ACC_SUFFIX_FILE="$HOME_AZ_DIR/storage-acc-random-suffix"
export TF_LOG="ERROR"

function random () 
{ 
    date "+%N"
}

function rdict ()
{
	python3 -c "print($1[${DQT}$2${DQT}])"
}

export -f random
export -f rdict


mkdir -p $HOME_AZ_DIR

if ! test -f "$STORAGE_ACC_SUFFIX_FILE"; then 
    echo $(random) > $STORAGE_ACC_SUFFIX_FILE
fi

STORAGE_ACC_SUFFIX=$(cat $STORAGE_ACC_SUFFIX_FILE)

export WORKSPACES=( "devs" "prod" "stag" "test" )
