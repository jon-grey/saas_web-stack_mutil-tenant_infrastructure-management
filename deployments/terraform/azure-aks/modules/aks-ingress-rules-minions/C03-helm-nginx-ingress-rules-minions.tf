resource "helm_release" "ingress_class" {
  namespace  = var.ingress_namespace
  name       = "helm-env-${var.env_id}-ingress-nginx-rules-minions"
  chart      = "${path.root}/helm/helm-ingress-rules-minions"
  version    = "0.0.1"
  
  set {
    name  = "ingress_class"
    value = var.ingress_controller_class
  }
  set {
    name  = "ingress_public_url"
    value = "${var.env_id}.${var.az_custom_domain}"
  }
  set {
    name  = "app_name"
    value = "app-frontend"
  }
  set {
    name  = "env_ns"
    value = var.env_ns
  }
  set {
    name  = "env_id"
    value = var.env_id
  }
  set {
    name  = "app_container_port"
    value = 80
  }

}



