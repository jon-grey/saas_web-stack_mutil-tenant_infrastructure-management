#!/bin/bash
set -euo pipefail

. ../exports.sh
. ../exports-private.sh

echo "
###########################################################################
#### Setup infrastructure management deployments
###########################################################################"
bash 01.deploy.azure.rbac.sh
bash 01.setup.local.cowsay.sh
bash 02.setup.local.terraform.sh
bash 02.setup.local.kubectl.sh


