# Managed DB Module

Creates cloud-managed PostgreSQL and Redis instances. Only one cloud provider's resources are created per deployment (controlled by `cloud_provider` variable).

## Resources by Cloud

### AWS (EKS)
- **RDS PostgreSQL 16**: gp3 storage, encrypted, 7-day backup retention
- **ElastiCache Redis 7.1**: Single node cluster
- Security groups scoped to VPC CIDR

### Azure (AKS)
- **Azure DB for PostgreSQL Flexible Server v16**: Delegated subnet, 7-day backup
- **Azure Cache for Redis**: Standard tier, TLS 1.2 only

### GCP (GKE)
- **Cloud SQL PostgreSQL 16**: Private IP via VPC peering, PD-SSD, auto-resize, PITR
- **Memorystore Redis 7.0**: Basic tier, 1GB

## Inputs

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `cloud_provider` | string | - | `eks`, `aks`, or `gke` |
| `name_prefix` | string | - | Resource name prefix |
| `db_username` | string | - | Database admin username |
| `db_password` | string | - | Database admin password (sensitive) |
| `db_instance_class` | string | - | DB instance size |
| `db_storage_gb` | number | - | Allocated storage in GB |
| `redis_node_type` | string | - | Redis node/tier type |
| `aws_vpc_id` | string | `""` | AWS VPC ID |
| `aws_private_subnet_ids` | list | `[]` | AWS private subnets |
| `azure_resource_group_name` | string | `""` | Azure resource group |
| `azure_subnet_id` | string | `""` | Azure DB subnet |
| `gcp_project` | string | `""` | GCP project |
| `gcp_network` | string | `""` | GCP VPC network |

## Outputs

| Output | Description |
|--------|-------------|
| `database_url` | Async connection URL (`postgresql+asyncpg://...`) |
| `database_sync_url` | Sync connection URL (`postgresql://...`) |
| `redis_url` | Redis connection URL |
| `database_endpoint` | Database hostname |
| `redis_endpoint` | Redis hostname |
