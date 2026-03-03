# ──────────────────────────────────────────────
# Azure Database for PostgreSQL Flexible Server + Azure Cache for Redis
# Only created when cloud_provider == "aks"
# ──────────────────────────────────────────────

# ── PostgreSQL Flexible Server ───────────────

resource "azurerm_postgresql_flexible_server" "postgres" {
  count = var.cloud_provider == "aks" ? 1 : 0

  name                   = "${var.name_prefix}-postgres"
  resource_group_name    = var.azure_resource_group_name
  location               = var.azure_location
  version                = "16"
  administrator_login    = var.db_username
  administrator_password = var.db_password

  storage_mb = var.db_storage_gb * 1024

  sku_name = var.db_instance_class

  delegated_subnet_id = var.azure_subnet_id

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-postgres"
  })

  lifecycle {
    ignore_changes = [
      zone,
      high_availability[0].standby_availability_zone,
    ]
  }
}

# ── PostgreSQL Database ──────────────────────

resource "azurerm_postgresql_flexible_server_database" "connectk" {
  count = var.cloud_provider == "aks" ? 1 : 0

  name      = "connectk"
  server_id = azurerm_postgresql_flexible_server.postgres[0].id
  collation = "en_US.utf8"
  charset   = "UTF8"
}

# ── Azure Cache for Redis ────────────────────

resource "azurerm_redis_cache" "redis" {
  count = var.cloud_provider == "aks" ? 1 : 0

  name                = "${var.name_prefix}-redis"
  resource_group_name = var.azure_resource_group_name
  location            = var.azure_location
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  non_ssl_port_enabled = false
  minimum_tls_version = "1.2"

  redis_configuration {}

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-redis"
  })
}
