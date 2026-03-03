# EKS Module

Creates an AWS EKS cluster with full networking and add-ons for running ConnectK.

## What It Creates

- **VPC**: 3-AZ public/private subnets, Internet Gateway, single NAT Gateway
- **EKS Cluster**: Managed control plane with API server (public + private endpoints)
- **Compute**: Managed node group OR EKS Auto Mode (via `use_auto_mode`)
- **IAM**: Cluster role, node role, OIDC provider, IRSA roles for EBS CSI + ALB Controller
- **Add-ons** (non-Auto Mode): vpc-cni, coredns, kube-proxy, aws-ebs-csi-driver
- **ALB Controller**: AWS Load Balancer Controller via Helm (non-Auto Mode)
- **ACM Certificate**: Optional, created when `domain_name` is set
- **StorageClass**: `connectk-ssd` using gp3 encrypted EBS volumes

## EKS Auto Mode

When `use_auto_mode = true`:
- No managed node group is created (EKS manages compute automatically)
- EBS CSI, ALB Controller, and core add-ons are built into Auto Mode
- StorageClass uses `ebs.csi.eks.amazonaws.com` provisioner
- Node IAM role is shared with the cluster role

When `use_auto_mode = false` (default):
- Managed node group with configurable instance types and scaling
- EBS CSI Driver installed as EKS add-on with IRSA
- ALB Controller installed via Helm with IRSA
- StorageClass uses `ebs.csi.aws.com` provisioner

## Inputs

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `name_prefix` | string | - | Resource name prefix |
| `cluster_version` | string | `1.31` | Kubernetes version |
| `vpc_cidr` | string | `10.0.0.0/16` | VPC CIDR block |
| `node_instance_types` | list(string) | `["t3.medium"]` | EC2 instance types |
| `node_desired_size` | number | `3` | Desired nodes |
| `node_min_size` | number | `2` | Min nodes |
| `node_max_size` | number | `5` | Max nodes |
| `use_auto_mode` | bool | `false` | Enable EKS Auto Mode |
| `domain_name` | string | `""` | Domain for ACM cert |
| `tags` | map(string) | `{}` | Resource tags |

## Outputs

| Output | Description |
|--------|-------------|
| `cluster_endpoint` | EKS API server endpoint |
| `cluster_ca_certificate` | Cluster CA (decoded) |
| `cluster_token` | Auth token (sensitive) |
| `cluster_name` | EKS cluster name |
| `vpc_id` | VPC ID |
| `private_subnet_ids` | Private subnet IDs |
| `public_subnet_ids` | Public subnet IDs |
| `oidc_provider_arn` | OIDC provider ARN (for IRSA) |
| `acm_certificate_arn` | ACM cert ARN (empty if no domain) |
