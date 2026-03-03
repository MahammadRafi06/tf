# ─────────────────────────────────────────────────
# GKE Cluster
# ─────────────────────────────────────────────────

resource "google_container_cluster" "this" {
  name     = var.name_prefix
  project  = var.project
  location = var.region

  min_master_version = var.cluster_version

  # Use separately managed node pool
  initial_node_count       = 1
  remove_default_node_pool = true

  network    = google_compute_network.this.name
  subnetwork = google_compute_subnetwork.this.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "${var.name_prefix}-pods"
    services_secondary_range_name = "${var.name_prefix}-services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.0.0/28"
  }

  # Workload Identity
  workload_identity_config {
    workload_pool = "${var.project}.svc.id.goog"
  }

  # Binary Authorization and other security
  release_channel {
    channel = "REGULAR"
  }

  deletion_protection = false
}

# ─────────────────────────────────────────────────
# Node Pool
# ─────────────────────────────────────────────────

resource "google_container_node_pool" "default" {
  name       = "${var.name_prefix}-default"
  project    = var.project
  location   = var.region
  cluster    = google_container_cluster.this.name
  node_count = var.node_count

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  management {
    auto_upgrade = true
    auto_repair  = true
  }

  node_config {
    machine_type = var.machine_type
    disk_size_gb = 50
    disk_type    = "pd-ssd"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    labels = var.tags
  }
}

# ─────────────────────────────────────────────────
# Auth token for Kubernetes provider
# ─────────────────────────────────────────────────

data "google_client_config" "this" {}
