# ──────────────────────────────────────────────
# ConnectK namespace and Kubernetes secrets
# ──────────────────────────────────────────────

resource "kubernetes_namespace" "connectk" {
  metadata {
    name = "connectk"

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "connectk"
    }
  }
}

# ── Backend application secrets ──────────────
# Keys match k8s/base/secrets.yaml

resource "kubernetes_secret" "backend_secrets" {
  metadata {
    name      = "backend-secrets"
    namespace = kubernetes_namespace.connectk.metadata[0].name

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "connectk"
    }
  }

  type = "Opaque"

  data = {
    DATABASE_URL                 = var.database_url
    DATABASE_SYNC_URL            = var.database_sync_url
    REDIS_URL                    = var.redis_url
    AZURE_TENANT_ID              = var.azure_tenant_id
    AZURE_CLIENT_ID              = var.azure_client_id
    AZURE_CLIENT_SECRET          = var.azure_client_secret
    INITIAL_ADMIN_ENTRA_GROUP_ID = var.initial_admin_entra_group_id
    ADMIN_GROUP_IDS              = var.admin_group_ids
    SESSION_SECRET_KEY           = var.session_secret_key
    CSRF_SECRET_KEY              = var.csrf_secret_key
    GIT_SSH_PRIVATE_KEY          = var.git_ssh_private_key
    ARGOCD_SERVER_URL            = var.argocd_server_url
  }
}

# ── Self-hosted PostgreSQL credentials ───────
# Only created when using self-hosted database strategy

resource "kubernetes_secret" "postgres_credentials" {
  count = var.db_strategy == "self-hosted" ? 1 : 0

  metadata {
    name      = "postgres-credentials"
    namespace = kubernetes_namespace.connectk.metadata[0].name

    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "connectk"
    }
  }

  type = "Opaque"

  data = {
    POSTGRES_USER     = "connectk"
    POSTGRES_PASSWORD = var.self_hosted_db_password
  }
}
