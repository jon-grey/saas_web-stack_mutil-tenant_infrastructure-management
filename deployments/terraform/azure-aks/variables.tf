variable "letencrypt_email" {
  description = "Email to be used with ClusterIssuer for CertManager"
}
variable "az_custom_domain" {
  description = "Custom domain ie. example.com used by AKS nginx ingress."
}
variable "az_client_id" {
  description = "Azure Kubernetes Service Cluster service principal"
}
variable "az_client_secret" {
  description = "Azure Kubernetes Service Cluster password"
}
variable "az_location" {
  description = "Azure resources location"
}
variable "az_resource_group_name" {
  description = "Azure resources group"
}
variable "az_container_registry_name" {
  description = "Azure container registry"
}
variable "az_aks_dns_prefix" {
  description = "Azure DNS prefix"
}
variable "az_aks_cluster_name" {
  description = "Azure AKS cluster name"
}
variable "az_aks_agent_count" {
  default = 1
}
variable "date" {
}
variable "az_aks_version" {
  default = "1.19.9"
}

variable "az_aks_admin_username" {
  description = "Azure AKS nodes admin account username"
}
variable "az_aks_default_namespace" {
  description = "Namespace where to deploy things on K8s"
  default     = "default"
}

# cert manager

variable "az_aks_cert_manager_namespace" {
  description = "Namespace where to deploy things on K8s"
  default     = "cert-manager-ns"
}
variable "az_aks_cluster_issuer_letsencrypt_staging_name" {
  default = "letsencrypt-staging"
}
variable "az_aks_cluster_issuer_letsencrypt_prod_name" {
  default = "letsencrypt-prod"
}

# ingress-nginx
variable "az_aks_ingress_name" {
  default = "helm-ingress-nginx"
}
variable "az_aks_ingress_namespace" {
  default = "ingress-nginx-ns"
}
variable "az_aks_ingress_controller_class" {
  default = "ingress-nginx-class"
}

variable "az_aks_ingress_controller_fqdn_dns_label" {
  default = "ingress-nginx-fqdn-dns"
}
variable "az_aks_ingress_certificate_letsencrypt_staging_name" {
  default = "tls-secret-staging"
}
variable "az_aks_ingress_certificate_letsencrypt_prod_name" {
  default = "tls-secret-staging"
}
variable "az_aks_ingress_certificate_letsencrypt_name" {
  default = "tls-secret-staging"
}

# customer app

variable "customer_id" {
  default = "demo000"
}

