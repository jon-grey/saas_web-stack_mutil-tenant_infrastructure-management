
# TODO

## Multiregion with Traffic Manager and Front Door

[Multi-region N-tier application - Azure Architecture Center](https://docs.microsoft.com/en-us/azure/architecture/reference-architectures/n-tier/multi-region-sql-server)

## Bastion for AKS and VM

[Azure Bastion &#8211; A real life use case](https://azapril.dev/2019/11/21/azure-bastion/)

## Split DevOps and Admin

- [ ] hide secrets from DevOps
- [ ] move secrets to KeyVault
- [ ] use keyvault in github actions [Azure/get-keyvault-secrets](https://github.com/Azure/get-keyvault-secrets)
- [ ] give secrets to multiple stages [Go crazy with GitHub Actions - Sander Knape](https://sanderknape.com/2021/01/go-crazy-github-actions/)
- [ ] create github secrets from code [gliech/create-github-secret-action](https://github.com/gliech/create-github-secret-action)

## AKS

### Networking

- [x] setup AKS based on VMs with kubenet
- [ ] setup AKS based on VMs and ACI with VNet to replace kubenet

### Access

- [x] RBAC service principal with cliend id and secret
- [x] user assigned managed identity
  - [x] - widely priviliged role of "Contributor"
  - [ ] - restrict priviliges for higher security

## Terraform

- [x] isolate terraform states:
  - [x] sharing one azure storage account with other github projects, 
  - [x] using different blobs to hold terraform states for different deployments

## Multistage environments

- [x] multistage namespaces:
  - [Using Helm to Deploy a Kubernetes Application to Multiple Environments (QA/Stage/Prod) - Codefresh](https://codefresh.io/helm-tutorial/helm-deployment-environments/) 
  - [codefresh-contrib/helm-promotion-sample-app](https://github.com/codefresh-contrib/helm-promotion-sample-app/blob/master/chart/values-qa.yaml) 
  - [codefresh-contrib/helm-promotion-sample-app](https://github.com/codefresh-contrib/helm-promotion-sample-app/blob/master/chart/values-staging.yaml)
- [ ] multistage clusters to replace multistage namespaces


# How To

## Create Github Secrets from Code

### Azure KeyVault

[justin-chizer/terraform-aks](https://github.com/justin-chizer/terraform-aks/blob/master/.github/workflows/build.yml)

```yml
name: 'Terraform GitHub Actions'
on:
  push:
    branches: [ master, dev ]
  pull_request:
    branches:
      - master
env:
  tf_working_dir: './terraform'
  tf_actions_version: 0.13.5
jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-18.04
    steps:      
    - name: 'Checkout'
      uses: actions/checkout@v2
    - uses: Azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    - uses: Azure/get-keyvault-secrets@v1
      with:
        keyvault: "chizerkeys"
        secrets: 'CLIENT-ID, CLIENT-SECRET, SUBSCRIPTION-ID, TENANT-ID'
      id: myGetSecretAction
    - name: 'Terraform Format'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: ${{ env.tf_actions_version }}
        tf_actions_subcommand: 'fmt'
        tf_actions_working_dir: ${{ env.tf_working_dir }}
        tf_actions_comment: true
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    - name: 'Terraform Init'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: ${{ env.tf_actions_version }}
        tf_actions_subcommand: 'init'
        tf_actions_working_dir: ${{ env.tf_working_dir }}
        tf_actions_comment: true
        args: -backend-config=client_id="${{ steps.myGetSecretAction.outputs.CLIENT-ID  }}" -backend-config=client_secret="${{ steps.myGetSecretAction.outputs.CLIENT-SECRET  }}" -backend-config=tenant_id="${{ steps.myGetSecretAction.outputs.TENANT-ID  }}" -backend-config=subscription_id="${{ steps.myGetSecretAction.outputs.SUBSCRIPTION-ID  }}" 
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    - name: 'Terraform Validate'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: ${{ env.tf_actions_version }}
        tf_actions_subcommand: 'validate'
        tf_actions_working_dir: ${{ env.tf_working_dir }}
        tf_actions_comment: true
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    - name: 'Terraform Plan'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: ${{ env.tf_actions_version }}
        tf_actions_subcommand: 'plan'
        tf_actions_working_dir: ${{ env.tf_working_dir }}
        tf_actions_comment: true
        args: -var=client_secret="${{ steps.myGetSecretAction.outputs.CLIENT-SECRET }}" -var=client_id="${{ steps.myGetSecretAction.outputs.CLIENT-ID }}" -var=subscription_id="${{ steps.myGetSecretAction.outputs.SUBSCRIPTION-ID }}" -var=tenant_id="${{ steps.myGetSecretAction.outputs.TENANT-ID }}"
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
    - name: 'Terraform Apply'
      uses: hashicorp/terraform-github-actions@master
      with:
        tf_actions_version: ${{ env.tf_actions_version }}
        tf_actions_subcommand: 'apply'
        tf_actions_working_dir: ${{ env.tf_working_dir }}
        tf_actions_comment: true
        args: -var=client_secret="${{ steps.myGetSecretAction.outputs.CLIENT-SECRET }}" -var=client_id="${{ steps.myGetSecretAction.outputs.CLIENT-ID }}" -var=subscription_id="${{ steps.myGetSecretAction.outputs.SUBSCRIPTION-ID }}" -var=tenant_id="${{ steps.myGetSecretAction.outputs.TENANT-ID }}"
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  terraformcheck:
    #needs: terraform
    name: 'AZ CLI'
    runs-on: ubuntu-18.04
    steps:
    - name: Azure login  
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}
    - name: Azure CLI check
      uses: azure/CLI@v1
      with:
        azcliversion: 2.3.1
        inlineScript: |
          az group list --query "[?name=='terraformsa']" | jq '.[].properties.provisioningState'
          az group list --query "[?name=='disneydemo2']" | jq '.[].properties.provisioningState'
          az vm list --query "[?name=='debianvm']" | jq '.[].provisioningState'
          az aks list --query "[?name=='aksdemoapril']" | jq '.[].provisioningState'
```

### Powershell

```yml
- name: Get Azure CLI
  uses: azure/login@v1
  with:
    creds: ${{ secrets.AZURE_CREDENTIALS }}

- name: Get Terraform
  uses: hashicorp/setup-terraform@v1
  with:
    terraform_version: '0.14.8'
    terraform_wrapper: false

- name: Terraform Init
  uses: Azure/powershell@v1
  env:
    AZURE_CREDENTIALS: ${{ secrets.AZURE_CREDENTIALS }}
  with:
    inlineScript: | 
      # Parse Azure secret into Terraform variables
      $servicePrincipal = ($env:AZURE_CREDENTIALS | ConvertFrom-Json)
      $env:ARM_CLIENT_ID       ??= $servicePrincipal.clientId
      $env:ARM_CLIENT_SECRET   ??= $servicePrincipal.clientSecret
      $env:ARM_SUBSCRIPTION_ID ??= $servicePrincipal.subscriptionId
      $env:ARM_TENANT_ID       ??= $servicePrincipal.tenantId
      terraform init
    azPSVersion: latest
    errorActionPreference: Stop
    failOnStandardError: true
```

### Bash

> WARNING: it will show secret value in logs, not feasible

[jon-grey/github-actions-secrets-creator](https://github.com/jon-grey/github-actions-secrets-creator)

```yml
steps:
  - uses: jon-grey/github-actions-secrets-creator@v1
    with:
      name: FRONT_DOOR_PASSWORD
      value: Eternia
      pa_token: ${{ secrets.PA_TOKEN }}
```

### Bash dynamic secrets

[add-mask doesn&#39;t work with workflow_dispatch inputs · Issue #643 · actions/runner](https://github.com/actions/runner/issues/643#issuecomment-823537871)


[How to use output from other action jobs](https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions#jobsjob_idoutputs)

Full example with inputs and outputs. Leaving for reference.

#### Inputs
Workflow file:

```yml
name: Test masking inputs
on:
  workflow_dispatch:
    inputs:
      secret:
        description: "secret value"
        required: true
      token:
        description: "token value"
        required: true
      secret_token:
        description: "secret_token value"
        required: true
jobs:
  test_masking_inputs:
    runs-on: ubuntu-20.04
    steps:
      - name: Test masking inputs
        id: add_mask
        run: |
          INP_SECRET=$(jq -r '.inputs.secret' $GITHUB_EVENT_PATH)
          INP_TOKEN=$(jq -r '.inputs.token' $GITHUB_EVENT_PATH)
          INP_SECRET_TOKEN=$(jq -r '.inputs.secret_token' $GITHUB_EVENT_PATH)
          echo Before mask
          echo $INP_SECRET
          echo $INP_TOKEN
          echo $INP_SECRET_TOKEN
          echo ::add-mask::$INP_SECRET
          echo ::add-mask::$INP_TOKEN
          echo ::add-mask::$INP_SECRET_TOKEN
          echo After mask
          echo $INP_SECRET
          echo $INP_TOKEN
          echo $INP_SECRET_TOKEN
          echo Setting output
          echo ::set-output name=secret::$INP_SECRET
          echo ::set-output name=token::$INP_TOKEN
          echo ::set-output name=secret_token::$INP_SECRET_TOKEN
          echo Setting environment variables
          echo SECRET="$INP_SECRET" >> $GITHUB_ENV
          echo TOKEN="$INP_TOKEN" >> $GITHUB_ENV
          echo SECRET_TOKEN="$INP_SECRET_TOKEN" >> $GITHUB_ENV

      - name: Check output from another step
        run: |
          echo "${{ steps.add_mask.outputs.secret }}"
          echo "${{ steps.add_mask.outputs.token }}"
          echo "${{ steps.add_mask.outputs.secret_token }}"

      - name: Check environment variables 1
        run: |
          echo "${{ env.SECRET }}"
          echo "${{ env.TOKEN }}"
          echo "${{ env.SECRET_TOKEN }}"

      - name: Check environment variables 2
        run: |
          echo $SECRET
          echo $TOKEN
          echo $SECRET_TOKEN
```
#### Output

Test masking inputs:
```
Before mask
(boo3)()
)wo%o()ho$o(
not_really..)(*^%%%%%%%^&*$
After mask
***
***
***
Setting output
Setting environment variables
```
Check output from another step (WRONG):
```
***
)wo%o()ho(
***
```
Check environment variables 1 (WRONG):
```
***
)wo%o()ho(
***
```
Check environment variables 2: (CORRECT?)
```
***
***
***
```
As I understand last case is the correct usage of masked input (use it as environment variable after placing it into GITHUB_ENV during add_mask step), as opposed to two previous steps where stars appear only because variable contains a SECRET substring in its name.