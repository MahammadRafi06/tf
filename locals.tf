locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(var.tags, {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
  })

  is_eks = var.cloud_provider == "eks"
  is_aks = var.cloud_provider == "aks"
  is_gke = var.cloud_provider == "gke"

  is_managed     = var.db_strategy == "managed"
  is_self_hosted = var.db_strategy == "self-hosted"

  # Auto-generate secrets if not provided
  session_secret = var.session_secret_key != "" ? var.session_secret_key : random_password.session_secret[0].result
  csrf_secret    = var.csrf_secret_key != "" ? var.csrf_secret_key : random_password.csrf_secret[0].result
  db_password    = var.db_password != "" ? var.db_password : random_password.db_password[0].result

  # ArgoCD URL
  argocd_url = var.install_argocd ? module.argocd[0].argocd_server_url : var.argocd_server_url

  # Database URLs
  database_url = local.is_managed ? module.managed_db[0].database_url : "postgresql+asyncpg://connectk:${local.db_password}@postgres:5432/connectk"
  database_sync_url = local.is_managed ? module.managed_db[0].database_sync_url : "postgresql://connectk:${local.db_password}@postgres:5432/connectk"
  redis_url = local.is_managed ? module.managed_db[0].redis_url : "redis://redis:6379/0"

  # Default managed DB sizes per cloud
  db_instance_class_default = {
    eks = "db.t3.medium"
    aks = "GP_Standard_D2s_v3"
    gke = "db-custom-2-7680"
  }
  redis_node_type_default = {
    eks = "cache.t3.micro"
    aks = "C1"
    gke = "BASIC"
  }
  effective_db_instance_class = var.db_instance_class != "" ? var.db_instance_class : local.db_instance_class_default[var.cloud_provider]
  effective_redis_node_type   = var.redis_node_type != "" ? var.redis_node_type : local.redis_node_type_default[var.cloud_provider]

  # Cluster connection - from modules or data sources
  _cluster_endpoint = var.create_cluster ? (
    local.is_eks ? module.eks[0].cluster_endpoint :
    local.is_aks ? module.aks[0].cluster_endpoint :
    local.is_gke ? module.gke[0].cluster_endpoint : ""
  ) : (
    local.is_eks ? data.aws_eks_cluster.existing[0].endpoint :
    local.is_aks ? "https://${data.azurerm_kubernetes_cluster.existing[0].fqdn}" :
    local.is_gke ? "https://${data.google_container_cluster.existing[0].endpoint}" : ""
  )

  _cluster_ca = var.create_cluster ? (
    local.is_eks ? module.eks[0].cluster_ca_certificate :
    local.is_aks ? module.aks[0].cluster_ca_certificate :
    local.is_gke ? module.gke[0].cluster_ca_certificate : ""
  ) : (
    local.is_eks ? base64decode(data.aws_eks_cluster.existing[0].certificate_authority[0].data) :
    local.is_aks ? base64decode(data.azurerm_kubernetes_cluster.existing[0].kube_config[0].cluster_ca_certificate) :
    local.is_gke ? base64decode(data.google_container_cluster.existing[0].master_auth[0].cluster_ca_certificate) : ""
  )

  _cluster_token = var.create_cluster ? (
    local.is_eks ? module.eks[0].cluster_token :
    local.is_aks ? module.aks[0].cluster_token :
    local.is_gke ? module.gke[0].cluster_token : ""
  ) : (
    local.is_eks ? data.aws_eks_cluster_auth.existing[0].token :
    local.is_aks ? data.azurerm_kubernetes_cluster.existing[0].kube_config[0].password :
    local.is_gke ? data.google_client_config.existing[0].access_token : ""
  )
}

resource "random_password" "session_secret" {
  count   = var.session_secret_key == "" ? 1 : 0
  length  = 64
  special = false
}

resource "random_password" "csrf_secret" {
  count   = var.csrf_secret_key == "" ? 1 : 0
  length  = 64
  special = false
}

resource "random_password" "db_password" {
  count            = var.db_password == "" ? 1 : 0
  length           = 32
  special          = true
  override_special = "!#$%()-_=+[]<>?"
}
