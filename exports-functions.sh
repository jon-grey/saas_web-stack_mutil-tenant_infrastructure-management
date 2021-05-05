#!/bin/bash
set -euo pipefail

export DQT='"'

function random () 
{ 
    date "+%N"
}

function rdict ()
{
	python3 -c "print($1[${DQT}$2${DQT}])"
}

function terraform_test()
{
    DEPLOYMENT=$1
    TF_LOG=$2
    CALLBACK=$3

    echo "
    ###########################################################################
    #### TEST TERRAFORM WITH: fmt, init, validate, plan
    #### DEPLOYMENT: $DEPLOYMENT
    ###########################################################################"
    (
        set -euo pipefail

        export TF_WARN_OUTPUT_ERRORS=1
        export TF_LOG="${TF_LOG:-ERROR}"

        cd ../deployments/terraform/${DEPLOYMENT}

        cowsay "Format terraform files $PWD..."
        terraform fmt
        echo "... with RC ==> $?"

        cowsay "Init terraform backend, $PWD..."
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

        cowsay "Validate terraform config files $PWD..."
        terraform validate
        echo "... with RC ==> $?"

        cowsay "Refresh terraform $PWD..."
        terraform refresh

        cowsay "Plan terraform $PWD..."
        mkdir -p ".files"
        terraform plan -out=".files/${DEPLOYMENT}.tfplan"
        echo "... with RC ==> $?"

        if [ ! -z "$CALLBACK" ]; then 
            cowsay "Execute callback function $PWD..."
            $CALLBACK
        fi
    )
}

function terraform_deploy()
{
    DEPLOYMENT=$1
    TF_LOG=$2
    CALLBACK=$3

    echo "
    ###########################################################################
    #### TEST TERRAFORM WITH: fmt, init, validate, plan
    #### DEPLOYMENT: $DEPLOYMENT
    ###########################################################################"
    (
        set -euo pipefail

        export TF_WARN_OUTPUT_ERRORS=1
        export TF_LOG="${TF_LOG:-ERROR}"

        cd ../deployments/terraform/${DEPLOYMENT}

        TFPLAN=""
        if test -f ".files/${DEPLOYMENT}.tfplan"; then
            TFPLAN=".files/${DEPLOYMENT}.tfplan"
        fi

        cowsay "Apply terraform $PWD..."
        terraform apply -auto-approve ${TFPLAN}
        echo "... with RC ==> $?"

        if [ ! -z "$CALLBACK" ]; then 
            cowsay "Execute callback function $PWD..."
            $CALLBACK
        fi
    )
}

export -f random
export -f rdict
export -f terraform_deploy
export -f terraform_test