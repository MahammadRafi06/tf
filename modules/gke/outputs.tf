output "cluster_endpoint" {
  value = "https://${google_container_cluster.this.endpoint}"
}

output "cluster_ca_certificate" {
  value = base64decode(google_container_cluster.this.master_auth[0].cluster_ca_certificate)
}

output "cluster_token" {
  value     = data.google_client_config.this.access_token
  sensitive = true
}

output "cluster_name" {
  value = google_container_cluster.this.name
}

output "network_name" {
  value = google_compute_network.this.name
}

output "subnetwork_name" {
  value = google_compute_subnetwork.this.name
}
