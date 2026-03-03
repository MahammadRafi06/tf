# ─────────────────────────────────────────────────
# NGINX Ingress Controller for GKE (via Helm)
# ─────────────────────────────────────────────────

resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  version    = "4.12.0"

  create_namespace = true

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  set {
    name  = "controller.replicaCount"
    value = "2"
  }

  depends_on = [
    google_container_cluster.this,
    google_container_node_pool.default,
  ]
}
