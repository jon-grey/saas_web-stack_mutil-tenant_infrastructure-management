resource "helm_release" "ingress_master" {
  namespace  = var.ingress_namespace
  name       = "helm-env-${var.env_id}-ingress-nginx-rules-master"
  chart      = "${path.root}/helm/helm-ingress-rules-master"
  version    = "0.0.1"

  set {
    name  = "ingress_master"
    value = "ingress-nginx-rules-master"
  }
  set {
    name  = "ingress_class"
    value = var.ingress_controller_class
  }
  set {
    name  = "ingress_public_url"
    value = "${var.env_id}.${var.az_custom_domain}"
  }
  set {
    name  = "ingress_secret_name"
    value = var.ingress_certificate_letsencrypt_name
  }
  set {
    name  = "cert_manager_cluster_issuer"
    value = "letsencrypt-staging"
  }
}






