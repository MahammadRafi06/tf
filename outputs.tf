output "cluster_endpoint" {
  description = "Kubernetes cluster API endpoint"
  value       = local._cluster_endpoint
}

output "cluster_name" {
  description = "Kubernetes cluster name"
  value       = var.create_cluster ? local.name_prefix : var.existing_cluster_name
}

output "kubeconfig_command" {
  description = "Command to configure kubectl"
  value = var.create_cluster ? (
    local.is_eks ? "aws eks update-kubeconfig --name ${local.name_prefix} --region ${var.aws_region}" :
    local.is_aks ? "az aks get-credentials --resource-group ${local.name_prefix}-rg --name ${local.name_prefix}" :
    local.is_gke ? "gcloud container clusters get-credentials ${local.name_prefix} --region ${var.gcp_region} --project ${var.gcp_project}" :
    ""
  ) : "Using existing cluster kubeconfig"
}

output "app_url" {
  description = "ConnectK application URL"
  value       = var.domain_name != "" ? "https://${var.domain_name}" : "Check: kubectl get ingress -n connectk"
}

output "argocd_url" {
  description = "ArgoCD server URL"
  value       = var.install_argocd ? local.argocd_url : var.argocd_server_url
}

output "argocd_admin_password_command" {
  description = "Command to get ArgoCD initial admin password"
  value       = var.install_argocd ? "kubectl -n ${var.argocd_namespace} get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d" : "N/A (ArgoCD pre-existing)"
}

output "database_endpoint" {
  description = "PostgreSQL endpoint"
  value       = local.is_managed ? module.managed_db[0].database_endpoint : "postgres.connectk.svc.cluster.local:5432"
}

output "redis_endpoint" {
  description = "Redis endpoint"
  value       = local.is_managed ? module.managed_db[0].redis_endpoint : "redis.connectk.svc.cluster.local:6379"
}

output "deployment_method" {
  description = "How ConnectK was deployed"
  value       = module.connectk_app.deployment_method
}

output "vpc_id" {
  description = "VPC/VNet ID (when cluster was created)"
  value = var.create_cluster ? (
    local.is_eks ? module.eks[0].vpc_id :
    local.is_aks ? module.aks[0].vnet_id :
    local.is_gke ? module.gke[0].network_name : ""
  ) : "Pre-existing cluster"
}
