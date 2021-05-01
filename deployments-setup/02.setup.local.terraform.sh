#!/bin/bash
set -euo pipefail

echo "
###########################################################################
#### Install terraform if not existing
###########################################################################"

if ! (test terraform &> /dev/null); then
    cowsay "Add the HashiCorp GPG key."
    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
    
    cowsay "Add the official HashiCorp Linux repository."
    sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
    
    cowsay "Update and install."
    sudo apt-get update && sudo apt-get install terraform
fi
