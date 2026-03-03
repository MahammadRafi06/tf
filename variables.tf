# ─────────────────────────────────────────────────
# Deployment scenario flags
# ─────────────────────────────────────────────────
variable "create_cluster" {
  description = "Create a new Kubernetes cluster. Set false to use an existing cluster."
  type        = bool
  default     = true
}

variable "install_argocd" {
  description = "Install ArgoCD on the cluster. Set false if ArgoCD is already installed."
  type        = bool
  default     = true
}

# ─────────────────────────────────────────────────
# Cloud provider selection
# ─────────────────────────────────────────────────
variable "cloud_provider" {
  description = "Target cloud: eks, aks, or gke"
  type        = string
  validation {
    condition     = contains(["eks", "aks", "gke"], var.cloud_provider)
    error_message = "cloud_provider must be one of: eks, aks, gke"
  }
}

# ─────────────────────────────────────────────────
# Database strategy
# ─────────────────────────────────────────────────
variable "db_strategy" {
  description = "Database strategy: self-hosted (StatefulSets) or managed (RDS/CloudSQL/Azure DB)"
  type        = string
  default     = "self-hosted"
  validation {
    condition     = contains(["self-hosted", "managed"], var.db_strategy)
    error_message = "db_strategy must be one of: self-hosted, managed"
  }
}

# ─────────────────────────────────────────────────
# General
# ─────────────────────────────────────────────────
variable "project_name" {
  description = "Project name used for naming all resources"
  type        = string
  default     = "connectk"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "domain_name" {
  description = "Domain name for the application (e.g., connectk.example.com). Leave empty to use LB DNS."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Common tags applied to all resources"
  type        = map(string)
  default     = {}
}

# ─────────────────────────────────────────────────
# Existing cluster (when create_cluster = false)
# ─────────────────────────────────────────────────
variable "existing_cluster_name" {
  description = "Name of existing cluster (when create_cluster = false)"
  type        = string
  default     = ""
}

variable "existing_eks_cluster_region" {
  description = "AWS region of existing EKS cluster"
  type        = string
  default     = ""
}

variable "existing_aks_resource_group" {
  description = "Resource group of existing AKS cluster"
  type        = string
  default     = ""
}

variable "existing_gke_project" {
  description = "GCP project of existing GKE cluster"
  type        = string
  default     = ""
}

variable "existing_gke_region" {
  description = "GCP region/zone of existing GKE cluster"
  type        = string
  default     = ""
}

# ─────────────────────────────────────────────────
# AWS / EKS
# ─────────────────────────────────────────────────
variable "aws_region" {
  description = "AWS region for EKS deployment"
  type        = string
  default     = "us-east-1"
}

variable "eks_cluster_version" {
  description = "EKS Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "eks_node_instance_types" {
  description = "Instance types for EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "eks_node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 3
}

variable "eks_node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 2
}

variable "eks_node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 5
}

variable "eks_use_auto_mode" {
  description = "Use EKS Auto Mode instead of managed node groups"
  type        = bool
  default     = false
}

variable "vpc_cidr" {
  description = "CIDR block for VPC (EKS)"
  type        = string
  default     = "10.0.0.0/16"
}

# ─────────────────────────────────────────────────
# Azure / AKS
# ─────────────────────────────────────────────────
variable "azure_location" {
  description = "Azure region for AKS deployment"
  type        = string
  default     = "eastus"
}

variable "aks_cluster_version" {
  description = "AKS Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "aks_node_vm_size" {
  description = "VM size for AKS system node pool"
  type        = string
  default     = "Standard_D2s_v5"
}

variable "aks_node_count" {
  description = "Initial node count for AKS"
  type        = number
  default     = 3
}

variable "aks_node_min_count" {
  description = "Minimum node count (autoscaler)"
  type        = number
  default     = 2
}

variable "aks_node_max_count" {
  description = "Maximum node count (autoscaler)"
  type        = number
  default     = 5
}

variable "aks_vnet_cidr" {
  description = "CIDR for AKS VNet"
  type        = string
  default     = "10.0.0.0/16"
}

# ─────────────────────────────────────────────────
# GCP / GKE
# ─────────────────────────────────────────────────
variable "gcp_project" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region for GKE"
  type        = string
  default     = "us-central1"
}

variable "gke_cluster_version" {
  description = "GKE minimum Kubernetes version"
  type        = string
  default     = "1.31"
}

variable "gke_machine_type" {
  description = "Machine type for GKE node pool"
  type        = string
  default     = "e2-standard-2"
}

variable "gke_node_count" {
  description = "Initial node count per zone"
  type        = number
  default     = 1
}

variable "gke_min_node_count" {
  description = "Minimum node count per zone"
  type        = number
  default     = 1
}

variable "gke_max_node_count" {
  description = "Maximum node count per zone"
  type        = number
  default     = 3
}

variable "gke_vpc_cidr" {
  description = "Primary CIDR for GKE subnet"
  type        = string
  default     = "10.0.0.0/20"
}

# ─────────────────────────────────────────────────
# Managed database
# ─────────────────────────────────────────────────
variable "db_instance_class" {
  description = "Database instance class (e.g., db.t3.medium, GP_Standard_D2s_v3, db-custom-2-7680)"
  type        = string
  default     = ""
}

variable "db_storage_gb" {
  description = "Allocated storage in GB for managed PostgreSQL"
  type        = number
  default     = 20
}

variable "db_username" {
  description = "Master username for managed PostgreSQL"
  type        = string
  default     = "connectk"
}

variable "db_password" {
  description = "Master password for managed PostgreSQL. Auto-generated if empty."
  type        = string
  default     = ""
  sensitive   = true
}

variable "redis_node_type" {
  description = "Node type for managed Redis"
  type        = string
  default     = ""
}

# ─────────────────────────────────────────────────
# ConnectK application secrets
# ─────────────────────────────────────────────────
variable "azure_tenant_id" {
  description = "Azure Entra ID tenant ID"
  type        = string
  sensitive   = true
}

variable "azure_client_id" {
  description = "Azure Entra ID application (client) ID"
  type        = string
  sensitive   = true
}

variable "azure_client_secret" {
  description = "Azure Entra ID client secret"
  type        = string
  sensitive   = true
}

variable "initial_admin_entra_group_id" {
  description = "Object ID of the initial admin Entra group"
  type        = string
  default     = ""
}

variable "admin_group_ids" {
  description = "Comma-separated Entra group IDs for admin access"
  type        = string
  default     = ""
}

variable "session_secret_key" {
  description = "Session encryption key (hex, 32 bytes). Auto-generated if empty."
  type        = string
  default     = ""
  sensitive   = true
}

variable "csrf_secret_key" {
  description = "CSRF token encryption key (hex, 32 bytes). Auto-generated if empty."
  type        = string
  default     = ""
  sensitive   = true
}

variable "git_ssh_private_key" {
  description = "Base64-encoded SSH private key for GitOps repos"
  type        = string
  default     = ""
  sensitive   = true
}

variable "argocd_server_url" {
  description = "ArgoCD server URL. Auto-populated when install_argocd = true."
  type        = string
  default     = ""
}

# ─────────────────────────────────────────────────
# ArgoCD
# ─────────────────────────────────────────────────
variable "argocd_chart_version" {
  description = "ArgoCD Helm chart version"
  type        = string
  default     = "7.7.10"
}

variable "argocd_namespace" {
  description = "Namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_server_service_type" {
  description = "Service type for ArgoCD server (LoadBalancer or ClusterIP)"
  type        = string
  default     = "LoadBalancer"
}

# ─────────────────────────────────────────────────
# Container images
# ─────────────────────────────────────────────────
variable "container_registry" {
  description = "Container registry URL (e.g., ghcr.io/username)"
  type        = string
  default     = "ghcr.io/mahammadrafi06"
}

variable "backend_image_tag" {
  description = "Backend container image tag"
  type        = string
  default     = "latest"
}

variable "frontend_image_tag" {
  description = "Frontend container image tag"
  type        = string
  default     = "latest"
}

# ─────────────────────────────────────────────────
# Git repository (for ArgoCD)
# ─────────────────────────────────────────────────
variable "git_repo_url" {
  description = "Git repository URL for ArgoCD to sync from"
  type        = string
  default     = "https://github.com/MahammadRafi06/connectk-backend.git"
}

variable "git_repo_branch" {
  description = "Git branch to track"
  type        = string
  default     = "main"
}
