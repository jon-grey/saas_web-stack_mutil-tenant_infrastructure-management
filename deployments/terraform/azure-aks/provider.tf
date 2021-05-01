

terraform {
  backend "azurerm" {
    resource_group_name  = "resource-group-demo-ops"
    storage_account_name = "storageops210849"
    container_name       = "az-terraform-state-288838384"
    key                  = "terraform.tfstate"
  }
}


