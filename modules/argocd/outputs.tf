output "argocd_server_url" {
  description = "Internal URL of the ArgoCD server"
  value       = "https://argocd-server.${var.namespace}.svc.cluster.local"
}

output "argocd_namespace" {
  description = "Namespace where ArgoCD is installed"
  value       = kubernetes_namespace.argocd.metadata[0].name
}
