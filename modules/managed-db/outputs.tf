output "database_url" {
  description = "Async database connection URL (postgresql+asyncpg://)"
  sensitive   = true
  value = (
    var.cloud_provider == "eks" ? "postgresql+asyncpg://${var.db_username}:${var.db_password}@${aws_db_instance.postgres[0].endpoint}/connectk" :
    var.cloud_provider == "aks" ? "postgresql+asyncpg://${var.db_username}:${var.db_password}@${azurerm_postgresql_flexible_server.postgres[0].fqdn}:5432/connectk?sslmode=require" :
    var.cloud_provider == "gke" ? "postgresql+asyncpg://${var.db_username}:${var.db_password}@${google_sql_database_instance.postgres[0].private_ip_address}:5432/connectk" :
    ""
  )
}

output "database_sync_url" {
  description = "Sync database connection URL (postgresql://)"
  sensitive   = true
  value = (
    var.cloud_provider == "eks" ? "postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.postgres[0].endpoint}/connectk" :
    var.cloud_provider == "aks" ? "postgresql://${var.db_username}:${var.db_password}@${azurerm_postgresql_flexible_server.postgres[0].fqdn}:5432/connectk?sslmode=require" :
    var.cloud_provider == "gke" ? "postgresql://${var.db_username}:${var.db_password}@${google_sql_database_instance.postgres[0].private_ip_address}:5432/connectk" :
    ""
  )
}

output "redis_url" {
  description = "Redis connection URL"
  sensitive   = true
  value = (
    var.cloud_provider == "eks" ? "redis://${aws_elasticache_cluster.redis[0].cache_nodes[0].address}:6379/0" :
    var.cloud_provider == "aks" ? "rediss://:${azurerm_redis_cache.redis[0].primary_access_key}@${azurerm_redis_cache.redis[0].hostname}:${azurerm_redis_cache.redis[0].ssl_port}/0" :
    var.cloud_provider == "gke" ? "redis://${google_redis_instance.redis[0].host}:${google_redis_instance.redis[0].port}/0" :
    ""
  )
}

output "database_endpoint" {
  description = "Database endpoint hostname"
  value = (
    var.cloud_provider == "eks" ? aws_db_instance.postgres[0].endpoint :
    var.cloud_provider == "aks" ? azurerm_postgresql_flexible_server.postgres[0].fqdn :
    var.cloud_provider == "gke" ? google_sql_database_instance.postgres[0].private_ip_address :
    ""
  )
}

output "redis_endpoint" {
  description = "Redis endpoint hostname"
  value = (
    var.cloud_provider == "eks" ? aws_elasticache_cluster.redis[0].cache_nodes[0].address :
    var.cloud_provider == "aks" ? azurerm_redis_cache.redis[0].hostname :
    var.cloud_provider == "gke" ? google_redis_instance.redis[0].host :
    ""
  )
}
