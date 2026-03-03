resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "connectk"
    }
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.chart_version
  namespace  = kubernetes_namespace.argocd.metadata[0].name

  timeout = 600
  wait    = true

  # ArgoCD server service type
  set {
    name  = "server.service.type"
    value = var.server_service_type
  }

  # Run server in insecure mode (TLS termination at ingress/LB)
  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }

  # Enable ApplicationSet controller
  set {
    name  = "applicationSet.enabled"
    value = "true"
  }
}
