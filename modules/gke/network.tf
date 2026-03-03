# ─────────────────────────────────────────────────
# VPC + Subnet with secondary ranges + Cloud NAT
# ─────────────────────────────────────────────────

resource "google_compute_network" "this" {
  name                    = "${var.name_prefix}-vpc"
  project                 = var.project
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "this" {
  name          = "${var.name_prefix}-subnet"
  project       = var.project
  region        = var.region
  network       = google_compute_network.this.id
  ip_cidr_range = var.vpc_cidr

  secondary_ip_range {
    range_name    = "${var.name_prefix}-pods"
    ip_cidr_range = "10.1.0.0/16"
  }

  secondary_ip_range {
    range_name    = "${var.name_prefix}-services"
    ip_cidr_range = "10.2.0.0/20"
  }

  private_ip_google_access = true
}

# ── Cloud Router + NAT (for private nodes) ──

resource "google_compute_router" "this" {
  name    = "${var.name_prefix}-router"
  project = var.project
  region  = var.region
  network = google_compute_network.this.id
}

resource "google_compute_router_nat" "this" {
  name                               = "${var.name_prefix}-nat"
  project                            = var.project
  region                             = var.region
  router                             = google_compute_router.this.name
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = false
    filter = "ERRORS_ONLY"
  }
}

# ── Firewall: allow internal communication ──

resource "google_compute_firewall" "internal" {
  name    = "${var.name_prefix}-allow-internal"
  project = var.project
  network = google_compute_network.this.name

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.vpc_cidr, "10.1.0.0/16", "10.2.0.0/20"]
}
