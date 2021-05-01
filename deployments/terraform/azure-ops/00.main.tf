# terraform {
#   backend "local" {
#     path = "terraform.tfstate"
#   }
# }

# data "terraform_remote_state" "local" {
#   backend = "local"

#   config = {
#     path = "terraform.tfstate"
#   }
# }

provider "azurerm" {
  features {}
}

# terraform {
#   backend "azurerm" { // can not use vars here, LOL
#     resource_group_name  = var.az_resource_group_name_ops
#     storage_account_name = var.az_storage_account_ops
#     container_name       = var.az_storage_tfstate
#     key                  = "terraform.tfstate"
#   }
# }

#######################################################################################
#### STAGE A 0.0 - Create ARG for Ops and Devs
#######################################################################################

# already exist
data "azurerm_resource_group" "ops" {
  name = var.az_resource_group_name_ops

}

resource "azurerm_resource_group" "devs" {
  name     = var.az_resource_group_name_devs
  location = var.az_location

  tags = {
    environment = "Devs"
  }
}
