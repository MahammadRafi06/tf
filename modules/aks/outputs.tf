output "cluster_endpoint" {
  value = azurerm_kubernetes_cluster.this.kube_config[0].host
}

output "cluster_ca_certificate" {
  value = base64decode(azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate)
}

output "cluster_token" {
  value     = azurerm_kubernetes_cluster.this.kube_config[0].password
  sensitive = true
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.this.name
}

output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "db_subnet_id" {
  value = azurerm_subnet.db.id
}
