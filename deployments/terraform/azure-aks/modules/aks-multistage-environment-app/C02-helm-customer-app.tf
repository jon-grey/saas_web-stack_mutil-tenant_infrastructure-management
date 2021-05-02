resource "kubernetes_namespace" "this" {
  metadata {
    name = "env-${var.env_id}-ns"
  }
}

resource "helm_release" "this" {
  namespace  = "env-${var.env_id}-ns"
  name       = "helm-env-${var.env_id}-app"
  chart      = "${path.root}/helm/helm-env-app"
  version    = "0.0.1"

  set {
    name  = "env_id"
    value =  var.env_id
  }
  set {
    name  = "name"
    value = "app-frontend"
  }
  set {
    name  = "registry"
    value = "mcr.microsoft.com"
  }
  set {
    name  = "image"
    value = "azuredocs/aks-helloworld"
  }
  set {
    name  = "tag"
    value = "v1"
  }
  set {
    name  = "containerPort"
    value = 80
  }
  set {
    name  = "replicas"
    value = 2
  }

  depends_on = [
      kubernetes_namespace.this,
  ]
}

