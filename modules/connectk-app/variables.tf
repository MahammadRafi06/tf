variable "use_argocd" {
  description = "Whether to deploy via ArgoCD (true) or direct kubectl apply (false)"
  type        = bool
}

variable "cloud_provider" {
  description = "Cloud provider: eks, aks, or gke"
  type        = string
}

variable "db_strategy" {
  description = "Database strategy: self-hosted or managed"
  type        = string
}

variable "database_url" {
  description = "Async database connection URL (postgresql+asyncpg://...)"
  type        = string
  sensitive   = true
}

variable "database_sync_url" {
  description = "Sync database connection URL (postgresql://...)"
  type        = string
  sensitive   = true
}

variable "redis_url" {
  description = "Redis connection URL"
  type        = string
  sensitive   = true
}

variable "azure_tenant_id" {
  description = "Azure AD / Entra ID tenant ID"
  type        = string
  sensitive   = true
}

variable "azure_client_id" {
  description = "Azure AD / Entra ID application (client) ID"
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure AD / Entra ID client secret"
  type        = string
  sensitive   = true
}

variable "initial_admin_entra_group_id" {
  description = "Entra group ID for initial admin users"
  type        = string
}

variable "admin_group_ids" {
  description = "Comma-separated list of Entra group IDs for admin access"
  type        = string
}

variable "session_secret_key" {
  description = "Secret key for session encryption (generate with: openssl rand -hex 32)"
  type        = string
  sensitive   = true
}

variable "csrf_secret_key" {
  description = "Secret key for CSRF protection (generate with: openssl rand -hex 32)"
  type        = string
  sensitive   = true
}

variable "git_ssh_private_key" {
  description = "Base64-encoded SSH private key for Git operations"
  type        = string
  sensitive   = true
}

variable "argocd_server_url" {
  description = "ArgoCD server URL for backend integration"
  type        = string
}

variable "self_hosted_db_password" {
  description = "Password for the self-hosted PostgreSQL instance"
  type        = string
  sensitive   = true
  default     = ""
}

variable "git_repo_url" {
  description = "Git repository URL for ArgoCD source"
  type        = string
}

variable "git_repo_branch" {
  description = "Git branch for ArgoCD to track"
  type        = string
}

variable "container_registry" {
  description = "Container registry URL (e.g., ghcr.io/org)"
  type        = string
}

variable "backend_image_tag" {
  description = "Docker image tag for the backend"
  type        = string
}

variable "frontend_image_tag" {
  description = "Docker image tag for the frontend"
  type        = string
}

variable "domain_name" {
  description = "Domain name for the application"
  type        = string
}
