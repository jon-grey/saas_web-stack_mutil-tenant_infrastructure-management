output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}
output "host" {
  value = azurerm_kubernetes_cluster.this.kube_config.0.host
}
output "client_key" {
  value = azurerm_kubernetes_cluster.this.kube_config.0.client_key
}
output "client_certificate" {
  value = azurerm_kubernetes_cluster.this.kube_config.0.client_certificate
}
output "cluster_ca_certificate" {
    value = azurerm_kubernetes_cluster.this.kube_config.0.cluster_ca_certificate
}
output "kube_config" {
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}
output "cluster_username" {
  value = azurerm_kubernetes_cluster.this.kube_config.0.username
}
output "cluster_password" {
  value = azurerm_kubernetes_cluster.this.kube_config.0.password
}
output "node_resource_group" {
  value = azurerm_kubernetes_cluster.this.node_resource_group
}
output "kubernetes_version" {
  value = azurerm_kubernetes_cluster.this.kubernetes_version
}
output "aks_private_key_pem" {
  value       = tls_private_key.this.private_key_pem
  sensitive   = true
}


