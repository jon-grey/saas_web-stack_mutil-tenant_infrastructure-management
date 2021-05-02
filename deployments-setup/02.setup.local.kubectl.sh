#!/bin/bash
set -euo pipefail

echo "
###########################################################################
#### Install kubectl if not existing
###########################################################################"

if ! (kubectl help &> /dev/null); then
    cowsay "Update the apt package index and install packages needed to use the Kubernetes apt repository:"
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl

    cowsay "Download the Google Cloud public signing key:"
    sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

    cowsay "Add the Kubernetes apt repository:"
    echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

    cowsay "Update apt package index with the new repository and install kubectl:"
    sudo apt-get update
    sudo apt-get install -y kubectl
fi
