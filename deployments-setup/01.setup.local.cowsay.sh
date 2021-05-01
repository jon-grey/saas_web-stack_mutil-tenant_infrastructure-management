#!/bin/bash
set -euo pipefail

echo "
###########################################################################
#### Install git-secret
###########################################################################"

if ! (test cowsay test &> /dev/null); then 
    sudo apt install fortune cowsay
fi

fortune | cowsay
