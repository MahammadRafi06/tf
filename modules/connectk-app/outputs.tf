output "app_namespace" {
  description = "Kubernetes namespace where ConnectK is deployed"
  value       = kubernetes_namespace.connectk.metadata[0].name
}

output "deployment_method" {
  description = "Deployment method used (argocd or direct)"
  value       = var.use_argocd ? "argocd" : "direct"
}
