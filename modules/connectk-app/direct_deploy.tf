# ──────────────────────────────────────────────
# Direct kubectl deployment (non-ArgoCD)
# Only created when use_argocd == false
# ──────────────────────────────────────────────

resource "null_resource" "direct_deploy" {
  count = var.use_argocd ? 0 : 1

  triggers = {
    backend_image_tag  = var.backend_image_tag
    frontend_image_tag = var.frontend_image_tag
    db_strategy        = var.db_strategy
    cloud_provider     = var.cloud_provider
  }

  provisioner "local-exec" {
    command = "kubectl apply -k k8s/overlays/${var.cloud_provider}/${var.db_strategy}"
  }

  depends_on = [
    kubernetes_namespace.connectk,
    kubernetes_secret.backend_secrets,
  ]
}
