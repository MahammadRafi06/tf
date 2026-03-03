# ──────────────────────────────────────────────
# GCP Cloud SQL (PostgreSQL) + Memorystore (Redis)
# Only created when cloud_provider == "gke"
# ──────────────────────────────────────────────

# ── Private IP allocation for Cloud SQL ──────

resource "google_compute_global_address" "private_ip" {
  count = var.cloud_provider == "gke" ? 1 : 0

  name          = "${var.name_prefix}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.gcp_network
  project       = var.gcp_project
}

# ── VPC peering connection for Cloud SQL ─────

resource "google_service_networking_connection" "private_vpc" {
  count = var.cloud_provider == "gke" ? 1 : 0

  network                 = var.gcp_network
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip[0].name]
}

# ── Cloud SQL PostgreSQL Instance ────────────

resource "google_sql_database_instance" "postgres" {
  count = var.cloud_provider == "gke" ? 1 : 0

  name             = "${var.name_prefix}-postgres"
  database_version = "POSTGRES_16"
  region           = var.gcp_region
  project          = var.gcp_project

  depends_on = [google_service_networking_connection.private_vpc]

  settings {
    tier              = var.db_instance_class
    disk_size         = var.db_storage_gb
    disk_type         = "PD_SSD"
    disk_autoresize   = true
    availability_type = "ZONAL"

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.gcp_network
      enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled                        = true
      start_time                     = "03:00"
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = 7
      }
    }

    user_labels = var.tags
  }

  deletion_protection = true
}

# ── Cloud SQL Database ───────────────────────

resource "google_sql_database" "connectk" {
  count = var.cloud_provider == "gke" ? 1 : 0

  name     = "connectk"
  instance = google_sql_database_instance.postgres[0].name
  project  = var.gcp_project
}

# ── Cloud SQL User ───────────────────────────

resource "google_sql_user" "postgres" {
  count = var.cloud_provider == "gke" ? 1 : 0

  name     = var.db_username
  instance = google_sql_database_instance.postgres[0].name
  password = var.db_password
  project  = var.gcp_project
}

# ── Memorystore Redis Instance ───────────────

resource "google_redis_instance" "redis" {
  count = var.cloud_provider == "gke" ? 1 : 0

  name           = "${var.name_prefix}-redis"
  tier           = var.redis_node_type
  memory_size_gb = 1
  region         = var.gcp_region
  project        = var.gcp_project

  redis_version     = "REDIS_7_0"
  authorized_network = var.gcp_network

  labels = var.tags
}
