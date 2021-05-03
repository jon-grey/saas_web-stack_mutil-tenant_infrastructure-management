
output "namespace" {
  value = kubernetes_namespace.env_app.metadata[0].name
}
