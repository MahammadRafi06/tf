# ─────────────────────────────────────────────────
# AKS Cluster
# ─────────────────────────────────────────────────

resource "azurerm_kubernetes_cluster" "this" {
  name                = var.name_prefix
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = var.name_prefix
  kubernetes_version  = var.cluster_version

  default_node_pool {
    name                = "system"
    vm_size             = var.node_vm_size
    node_count          = var.node_count
    min_count           = var.node_min_count
    max_count           = var.node_max_count
    auto_scaling_enabled = true
    vnet_subnet_id      = azurerm_subnet.aks.id
    os_disk_size_gb     = 50
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "172.16.0.0/16"
    dns_service_ip    = "172.16.0.10"
  }

  tags = var.tags
}

# ─────────────────────────────────────────────────
# Auth token for Kubernetes provider
# ─────────────────────────────────────────────────

# AKS provides the kubeconfig directly via the resource attributes
