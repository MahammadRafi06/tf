# ─────────────────────────────────────────────────
# Provider configuration
# ─────────────────────────────────────────────────

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = local.common_tags
  }
}

provider "azurerm" {
  features {}
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
}

# ─────────────────────────────────────────────────
# Data sources for existing clusters
# ─────────────────────────────────────────────────

data "aws_eks_cluster" "existing" {
  count = (!var.create_cluster && local.is_eks) ? 1 : 0
  name  = var.existing_cluster_name
}

data "aws_eks_cluster_auth" "existing" {
  count = (!var.create_cluster && local.is_eks) ? 1 : 0
  name  = var.existing_cluster_name
}

data "azurerm_kubernetes_cluster" "existing" {
  count               = (!var.create_cluster && local.is_aks) ? 1 : 0
  name                = var.existing_cluster_name
  resource_group_name = var.existing_aks_resource_group
}

data "google_container_cluster" "existing" {
  count    = (!var.create_cluster && local.is_gke) ? 1 : 0
  name     = var.existing_cluster_name
  location = var.existing_gke_region
  project  = var.existing_gke_project
}

data "google_client_config" "existing" {
  count = (!var.create_cluster && local.is_gke) ? 1 : 0
}

# ─────────────────────────────────────────────────
# Kubernetes / Helm / Kubectl providers
# ─────────────────────────────────────────────────

provider "kubernetes" {
  host                   = local._cluster_endpoint
  cluster_ca_certificate = local._cluster_ca
  token                  = local._cluster_token
}

provider "helm" {
  kubernetes {
    host                   = local._cluster_endpoint
    cluster_ca_certificate = local._cluster_ca
    token                  = local._cluster_token
  }
}

provider "kubectl" {
  host                   = local._cluster_endpoint
  cluster_ca_certificate = local._cluster_ca
  token                  = local._cluster_token
  load_config_file       = false
}

# ─────────────────────────────────────────────────
# LAYER 1: Cluster creation (conditional)
# ─────────────────────────────────────────────────

module "eks" {
  source = "./modules/eks"
  count  = (var.create_cluster && local.is_eks) ? 1 : 0

  name_prefix         = local.name_prefix
  cluster_version     = var.eks_cluster_version
  vpc_cidr            = var.vpc_cidr
  node_instance_types = var.eks_node_instance_types
  node_desired_size   = var.eks_node_desired_size
  node_min_size       = var.eks_node_min_size
  node_max_size       = var.eks_node_max_size
  use_auto_mode       = var.eks_use_auto_mode
  domain_name         = var.domain_name
  tags                = local.common_tags
}

module "aks" {
  source = "./modules/aks"
  count  = (var.create_cluster && local.is_aks) ? 1 : 0

  name_prefix     = local.name_prefix
  location        = var.azure_location
  cluster_version = var.aks_cluster_version
  node_vm_size    = var.aks_node_vm_size
  node_count      = var.aks_node_count
  node_min_count  = var.aks_node_min_count
  node_max_count  = var.aks_node_max_count
  vnet_cidr       = var.aks_vnet_cidr
  tags            = local.common_tags
}

module "gke" {
  source = "./modules/gke"
  count  = (var.create_cluster && local.is_gke) ? 1 : 0

  name_prefix     = local.name_prefix
  project         = var.gcp_project
  region          = var.gcp_region
  cluster_version = var.gke_cluster_version
  machine_type    = var.gke_machine_type
  node_count      = var.gke_node_count
  min_node_count  = var.gke_min_node_count
  max_node_count  = var.gke_max_node_count
  vpc_cidr        = var.gke_vpc_cidr
  tags            = local.common_tags
}

# ─────────────────────────────────────────────────
# LAYER 2: Managed databases (conditional)
# ─────────────────────────────────────────────────

module "managed_db" {
  source = "./modules/managed-db"
  count  = local.is_managed ? 1 : 0

  depends_on = [module.eks, module.aks, module.gke]

  cloud_provider    = var.cloud_provider
  name_prefix       = local.name_prefix
  db_username       = var.db_username
  db_password       = local.db_password
  db_instance_class = local.effective_db_instance_class
  db_storage_gb     = var.db_storage_gb
  redis_node_type   = local.effective_redis_node_type
  tags              = local.common_tags

  # EKS networking
  aws_vpc_id             = local.is_eks && var.create_cluster ? module.eks[0].vpc_id : ""
  aws_private_subnet_ids = local.is_eks && var.create_cluster ? module.eks[0].private_subnet_ids : []
  aws_region             = var.aws_region

  # AKS networking
  azure_resource_group_name = local.is_aks && var.create_cluster ? module.aks[0].resource_group_name : var.existing_aks_resource_group
  azure_location            = var.azure_location
  azure_subnet_id           = local.is_aks && var.create_cluster ? module.aks[0].db_subnet_id : ""

  # GKE networking
  gcp_project = var.gcp_project
  gcp_region  = var.gcp_region
  gcp_network = local.is_gke && var.create_cluster ? module.gke[0].network_name : ""
}

# ─────────────────────────────────────────────────
# LAYER 3: ArgoCD (conditional)
# ─────────────────────────────────────────────────

module "argocd" {
  source = "./modules/argocd"
  count  = var.install_argocd ? 1 : 0

  depends_on = [module.eks, module.aks, module.gke]

  namespace           = var.argocd_namespace
  chart_version       = var.argocd_chart_version
  server_service_type = var.argocd_server_service_type
  cloud_provider      = var.cloud_provider
  git_repo_url        = var.git_repo_url
}

# ─────────────────────────────────────────────────
# LAYER 4: ConnectK application
# ─────────────────────────────────────────────────

module "connectk_app" {
  source = "./modules/connectk-app"

  depends_on = [module.argocd, module.managed_db, module.eks, module.aks, module.gke]

  use_argocd     = var.install_argocd || var.argocd_server_url != ""
  cloud_provider = var.cloud_provider
  db_strategy    = var.db_strategy

  # Secrets
  database_url                 = local.database_url
  database_sync_url            = local.database_sync_url
  redis_url                    = local.redis_url
  azure_tenant_id              = var.azure_tenant_id
  azure_client_id              = var.azure_client_id
  azure_client_secret          = var.azure_client_secret
  initial_admin_entra_group_id = var.initial_admin_entra_group_id
  admin_group_ids              = var.admin_group_ids
  session_secret_key           = local.session_secret
  csrf_secret_key              = local.csrf_secret
  git_ssh_private_key          = var.git_ssh_private_key
  argocd_server_url            = local.argocd_url
  self_hosted_db_password      = local.is_self_hosted ? local.db_password : ""

  # ArgoCD config
  git_repo_url    = var.git_repo_url
  git_repo_branch = var.git_repo_branch

  # Direct deploy config
  container_registry = var.container_registry
  backend_image_tag  = var.backend_image_tag
  frontend_image_tag = var.frontend_image_tag
  domain_name        = var.domain_name
}
