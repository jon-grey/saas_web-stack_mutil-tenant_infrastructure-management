
#######################################################################################
#### STAGE C 1.1 - Deploy multistage environment deployment
#######################################################################################

module "c_multistage_environment_app" {
  source = "../aks-multistage-environment-app"
  env_id = var.env_id
}

#######################################################################################
#### STAGE C 1.1 - Deploy multistage env nginx rules master
#######################################################################################

module "c_multistage_environment_ingress_rules_master" {
  source = "../aks-ingress-rules-master"

  env_id = var.env_id

  ingress_namespace = var.ingress_namespace
  ingress_ip_address = var.ingress_ip_address
  ingress_controller_class = var.ingress_controller_class
  az_custom_domain = var.az_custom_domain
  ingress_certificate_letsencrypt_name = var.ingress_certificate_letsencrypt_name

}

#######################################################################################
#### STAGE C 2.0 - Deploy multistage env  nginx rules minions (for mergeable updates of rules)
#######################################################################################

module "c_multistage_environment_ingress_rules_minions" {
  source = "../aks-ingress-rules-minions"
  
  env_id = var.env_id
  env_ns = module.c_multistage_environment_app.namespace

  ingress_namespace = var.ingress_namespace
  ingress_controller_class = var.ingress_controller_class
  az_custom_domain = var.az_custom_domain


}



