variable "namespace" {
  description = "Kubernetes namespace for ArgoCD installation"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "7.7.10"
}

variable "server_service_type" {
  description = "Service type for the ArgoCD server (LoadBalancer, ClusterIP, NodePort)"
  type        = string
  default     = "LoadBalancer"
}

variable "cloud_provider" {
  description = "Cloud provider (eks, aks, gke)"
  type        = string
}

variable "git_repo_url" {
  description = "Git repository URL for ArgoCD to watch"
  type        = string
  default     = "https://github.com/MahammadRafi06/connectk-backend.git"
}
