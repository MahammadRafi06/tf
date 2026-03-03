# AKS Module

Creates an Azure AKS cluster with networking and ingress for running ConnectK.

## What It Creates

- **Resource Group**: Dedicated Azure resource group
- **VNet**: Virtual network with AKS subnet and DB-delegated subnet
- **NSG**: Network security group for the AKS subnet
- **AKS Cluster**: Managed cluster with system-assigned identity, autoscaling node pool
- **NGINX Ingress**: Ingress controller via Helm with Azure LoadBalancer
- **StorageClass**: `connectk-ssd` using Azure StandardSSD_LRS

## Network Architecture

- AKS subnet: First /20 of the VNet CIDR (node IPs)
- DB subnet: Second /20 of the VNet CIDR (delegated to PostgreSQL Flexible Server)
- Azure CNI network plugin with network policies
- Service CIDR: `172.16.0.0/16`

## Inputs

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `name_prefix` | string | - | Resource name prefix |
| `location` | string | `eastus` | Azure region |
| `cluster_version` | string | `1.31` | Kubernetes version |
| `node_vm_size` | string | `Standard_D2s_v5` | VM size |
| `node_count` | number | `3` | Initial node count |
| `node_min_count` | number | `2` | Min nodes (autoscaler) |
| `node_max_count` | number | `5` | Max nodes (autoscaler) |
| `vnet_cidr` | string | `10.0.0.0/16` | VNet CIDR |
| `tags` | map(string) | `{}` | Resource tags |

## Outputs

| Output | Description |
|--------|-------------|
| `cluster_endpoint` | AKS API server URL |
| `cluster_ca_certificate` | Cluster CA (decoded) |
| `cluster_token` | Auth token (sensitive) |
| `cluster_name` | AKS cluster name |
| `resource_group_name` | Resource group name |
| `vnet_id` | VNet ID |
| `db_subnet_id` | DB-delegated subnet ID |
