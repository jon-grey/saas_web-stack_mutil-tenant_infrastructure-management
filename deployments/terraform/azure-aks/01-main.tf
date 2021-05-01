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

#######################################################################################
#### STAGE A 1.0
#######################################################################################

data "azurerm_resource_group" "devs" {
  name = var.az_resource_group_name
  # location = var.az_location

  # tags = {
  #   environment = "Demo"
  # }
}

#######################################################################################
#### STAGE A 1.1
#######################################################################################

module "a_acr" {
  source = "./modules/acr"

  location                = var.az_location
  resource_group_name     = var.az_resource_group_name
  container_registry_name = var.az_container_registry_name

  depends_on = [
  ]
}
#######################################################################################
#### STAGE A 1.1
#######################################################################################

module "a_aks_cluster" {
  source = "./modules/aks-cluster"

  resource_group_name = var.az_resource_group_name
  location            = var.az_location
  cluster_name        = var.az_aks_cluster_name
  dns_prefix          = var.az_aks_dns_prefix
  admin_username      = var.az_aks_admin_username
  agent_count         = var.az_aks_agent_count
  client_id           = var.az_client_id
  client_secret       = var.az_client_secret
  kubernetes_version  = var.az_aks_version

  depends_on = [
  ]
}
#######################################################################################
#### STAGE A 2.0
#######################################################################################

resource "local_file" "aksconfig" {
  content  = module.a_aks_cluster.kube_config
  filename = pathexpand("~/.kube/aksconfig")

  depends_on = [
    module.a_aks_cluster.azurerm_kubernetes_cluster
  ]
}



#######################################################################################
#### STAGE B 1.0 - Deploy AKS cluster common resources
#######################################################################################
provider "kubernetes" {
  host                   = module.a_aks_cluster.host
  client_key             = base64decode(module.a_aks_cluster.client_key)
  client_certificate     = base64decode(module.a_aks_cluster.client_certificate)
  cluster_ca_certificate = base64decode(module.a_aks_cluster.cluster_ca_certificate)
  # load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = module.a_aks_cluster.host
    client_key             = base64decode(module.a_aks_cluster.client_key)
    client_certificate     = base64decode(module.a_aks_cluster.client_certificate)
    cluster_ca_certificate = base64decode(module.a_aks_cluster.cluster_ca_certificate)
    # load_config_file       = false
  }
}


#######################################################################################
#### STAGE B 1.0 - Deploy ASK/cert-manager-ns/cert-manager
#######################################################################################
module "b_cert_manager" {
  source = "./modules/cert-manager"

  email                                        = var.letencrypt_email
  cert_manager_namespace                       = var.az_aks_cert_manager_namespace
  cluster_issuer_letsencrypt_staging_name      = var.az_aks_cluster_issuer_letsencrypt_staging_name
  cluster_name                                 = var.az_aks_cluster_name
  ingress_controller_class                     = var.az_aks_ingress_controller_class
  ingress_namespace                            = var.az_aks_ingress_namespace
  ingress_certificate_letsencrypt_staging_name = var.az_aks_ingress_certificate_letsencrypt_staging_name
  ingress_azurerm_dns_zone                     = var.az_custom_domain

  host                   = module.a_aks_cluster.host
  client_key             = module.a_aks_cluster.client_key
  client_certificate     = module.a_aks_cluster.client_certificate
  cluster_ca_certificate = module.a_aks_cluster.cluster_ca_certificate

  depends_on = [
    module.a_aks_cluster.azurerm_kubernetes_cluster,
    local_file.aksconfig
  ]
}

#######################################################################################
#### STAGE B 1.0 - Deploy custom domain for customer app
#######################################################################################
module "b_custom_domain" {
  source = "./modules/custom-domain"

  location                        = var.az_location
  ingress_azurerm_dns_zone        = var.az_custom_domain
  aks_cluster_node_resource_group = module.a_aks_cluster.node_resource_group

  depends_on = [
    module.a_aks_cluster,
    local_file.aksconfig
  ]
}

#######################################################################################
#### STAGE B 2.0 - Deploy ingress nginx controller
#######################################################################################
module "b_ingress_nginx_controller" {
  source = "./modules/ingress-controller"

  ingress_controller_class = var.az_aks_ingress_controller_class
  ingress_namespace        = var.az_aks_ingress_namespace
  ingress_name             = var.az_aks_ingress_name
  ingress_ip_address       = module.b_custom_domain.ip_address

  depends_on = [
    module.a_aks_cluster.azurerm_kubernetes_cluster,
    module.b_custom_domain,
    local_file.aksconfig,
  ]
}

#######################################################################################
#### STAGE C 1.0 - Deploy customers resources
#######################################################################################

variable "customers_list" {
  description = "Map of customers IDs"
  default = [
    "demo000",
    "demo001",
    "demo002",
  ]
}

module "c_customers" {
  source = "./modules/customer"

  for_each    = toset(var.customers_list)
  customer_id = each.key

  # ingress_name = var.ingress_name
  ingress_namespace                    = var.az_aks_ingress_namespace
  ingress_controller_class             = var.az_aks_ingress_controller_class
  ingress_azurerm_dns_zone             = var.az_custom_domain
  ingress_certificate_letsencrypt_name = var.az_aks_ingress_certificate_letsencrypt_name

  ingress_ip_address = module.b_custom_domain.ip_address

  depends_on = [
    module.a_aks_cluster.azurerm_kubernetes_cluster,
    module.a_acr.azurerm_container_registry,
    module.b_custom_domain,
    module.b_cert_manager,
    local_file.aksconfig,
  ]
}
