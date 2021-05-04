
# TODO

## Split DevOps and Admin

- [ ] hide secrets from DevOps
- [ ] move secrets to KeyVault
- [ ] use keyvault in github actions [Azure/get-keyvault-secrets](https://github.com/Azure/get-keyvault-secrets)
- [ ] give secrets to multiple stages [Go crazy with GitHub Actions - Sander Knape](https://sanderknape.com/2021/01/go-crazy-github-actions/)
- [ ] ~~create github secrets from code [gliech/create-github-secret-action](https://github.com/gliech/create-github-secret-action)~~ (WARNING it will show secret value, not feasible)

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
