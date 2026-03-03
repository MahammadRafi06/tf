# GKE Module

Creates a Google GKE cluster with networking and ingress for running ConnectK.

## What It Creates

- **VPC**: Custom VPC with auto-create disabled
- **Subnet**: Primary range + secondary ranges for pods and services
- **Cloud NAT**: NAT gateway for private node internet access
- **Firewall**: Internal communication rules
- **GKE Cluster**: Private cluster with Workload Identity, regular release channel
- **Node Pool**: Configurable machine type with autoscaling
- **NGINX Ingress**: Ingress controller via Helm
- **StorageClass**: `connectk-ssd` using pd-ssd

## Network Architecture

- Primary subnet CIDR: configurable (default `10.0.0.0/20`)
- Pod secondary range: `10.1.0.0/16`
- Service secondary range: `10.2.0.0/20`
- Master CIDR: `172.16.0.0/28`
- Private nodes with public control plane endpoint

## Inputs

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `name_prefix` | string | - | Resource name prefix |
| `project` | string | - | GCP project ID |
| `region` | string | `us-central1` | GCP region |
| `cluster_version` | string | `1.31` | Min master version |
| `machine_type` | string | `e2-standard-2` | Node machine type |
| `node_count` | number | `1` | Nodes per zone |
| `min_node_count` | number | `1` | Min nodes per zone |
| `max_node_count` | number | `3` | Max nodes per zone |
| `vpc_cidr` | string | `10.0.0.0/20` | Primary subnet CIDR |
| `tags` | map(string) | `{}` | Resource labels |

## Outputs

| Output | Description |
|--------|-------------|
| `cluster_endpoint` | GKE API server URL (https://) |
| `cluster_ca_certificate` | Cluster CA (decoded) |
| `cluster_token` | Auth token (sensitive) |
| `cluster_name` | GKE cluster name |
| `network_name` | VPC network name |
| `subnetwork_name` | Subnet name |
