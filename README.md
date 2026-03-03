# ConnectK Terraform Infrastructure

Terraform IaC for deploying [ConnectK](https://github.com/MahammadRafi06/connectk-backend) across AWS EKS, Azure AKS, and Google GKE. Supports greenfield cluster creation, existing cluster adoption, and multiple database strategies -- all controlled via boolean flags.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     terraform.tfvars                            │
│  create_cluster · install_argocd · cloud_provider · db_strategy │
└──────────────┬──────────────────────────────────────────────────┘
               │
   ┌───────────▼───────────┐
   │      Root Module      │
   │  main.tf / locals.tf  │
   └───┬───┬───┬───┬───┬───┘
       │   │   │   │   │
 ┌─────▼┐ ┌▼──┐ ┌─▼─┐ │  ┌──────▼──────┐
 │ eks  │ │aks│ │gke│ │  │ managed-db  │
 │ aks  │ │   │ │   │ │  │ (RDS/Cloud  │
 │ gke  │ └───┘ └───┘ │  │  SQL/Azure) │
 └──────┘              │  └─────────────┘
              ┌────────▼──────┐
              │    argocd     │
              │  (Helm chart) │
              └───────┬───────┘
              ┌───────▼───────┐
              │ connectk-app  │
              │ (secrets +    │
              │  deploy)      │
              └───────────────┘
```

## Deployment Scenarios

| Scenario | `create_cluster` | `install_argocd` | What Terraform creates |
|----------|:---:|:---:|---|
| **Greenfield** | `true` | `true` | VPC + Cluster + add-ons + ArgoCD + ConnectK app |
| **Existing cluster** | `false` | `true` | ArgoCD + ConnectK app (onto your cluster) |
| **Existing cluster + ArgoCD** | `false` | `false` | ConnectK app only |

Each scenario works with any combination of:
- **Cloud provider**: `eks` / `aks` / `gke`
- **Database strategy**: `self-hosted` (StatefulSets) / `managed` (RDS, CloudSQL, Azure DB)

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.0
- Cloud CLI authenticated:
  - **EKS**: `aws configure` (IAM user/role with EKS + VPC + IAM + ELB + ACM permissions)
  - **AKS**: `az login` (Contributor on the subscription)
  - **GKE**: `gcloud auth application-default login` (Editor on the project)
- `kubectl` installed (for direct deploy fallback)
- An Azure Entra ID app registration (for ConnectK authentication)

## Quick Start

### 1. Clone and configure

```bash
git clone https://github.com/MahammadRafi06/tf.git
cd tf
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values. At minimum:

```hcl
cloud_provider      = "eks"          # or "aks" / "gke"
azure_tenant_id     = "..."          # Entra ID tenant
azure_client_id     = "..."          # Entra ID app client ID
azure_client_secret = "..."          # Entra ID app client secret
```

### 2. Deploy

**For existing clusters** (no chicken-and-egg problem):

```bash
terraform init
terraform plan
terraform apply
```

**For greenfield** (new cluster + K8s resources):

Two-phase apply is required because the `kubernetes`/`helm` providers need a cluster endpoint at plan time:

```bash
terraform init

# Phase 1: Create the cluster
terraform apply -target=module.eks    # or module.aks / module.gke

# Phase 2: Deploy everything else
terraform apply
```

### 3. Connect to the cluster

Terraform outputs the kubeconfig command:

```bash
# EKS
aws eks update-kubeconfig --name connectk-prod --region us-east-1

# AKS
az aks get-credentials --resource-group connectk-prod-rg --name connectk-prod

# GKE
gcloud container clusters get-credentials connectk-prod --region us-central1 --project my-project
```

### 4. Get ArgoCD admin password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

## Directory Structure

```
.
├── main.tf                          # Root orchestrator - conditional module calls
├── variables.tf                     # All input variables with validation
├── locals.tf                        # Derived values, auto-generated secrets
├── outputs.tf                       # Cluster endpoint, app URL, kubeconfig cmd
├── versions.tf                      # Provider version constraints
├── terraform.tfvars.example         # Documented example configuration
│
└── modules/
    ├── eks/                         # AWS EKS cluster
    │   ├── vpc.tf                   # VPC, 3-AZ public/private subnets, NAT, IGW
    │   ├── cluster.tf               # EKS cluster + managed node group / Auto Mode
    │   ├── iam.tf                   # OIDC, IRSA roles (EBS CSI, ALB Controller)
    │   ├── addons.tf                # vpc-cni, coredns, kube-proxy, EBS CSI
    │   ├── alb_controller.tf        # AWS Load Balancer Controller (Helm)
    │   ├── acm.tf                   # ACM certificate (when domain_name set)
    │   ├── storage_class.tf         # connectk-ssd StorageClass (gp3, encrypted)
    │   ├── variables.tf             # Module inputs
    │   └── outputs.tf               # endpoint, CA, token, VPC ID, subnet IDs
    │
    ├── aks/                         # Azure AKS cluster
    │   ├── resource_group.tf        # Azure Resource Group
    │   ├── network.tf               # VNet, AKS subnet, DB subnet (delegated), NSG
    │   ├── cluster.tf               # AKS cluster + system node pool (autoscale)
    │   ├── ingress.tf               # NGINX Ingress Controller (Helm)
    │   ├── storage_class.tf         # connectk-ssd StorageClass (StandardSSD_LRS)
    │   ├── variables.tf             # Module inputs
    │   └── outputs.tf               # endpoint, CA, token, resource group, VNet
    │
    ├── gke/                         # Google GKE cluster
    │   ├── network.tf               # VPC, subnet + pod/service secondary ranges, Cloud NAT
    │   ├── cluster.tf               # GKE cluster + node pool (Workload Identity)
    │   ├── ingress.tf               # NGINX Ingress Controller (Helm)
    │   ├── storage_class.tf         # connectk-ssd StorageClass (pd-ssd)
    │   ├── variables.tf             # Module inputs
    │   └── outputs.tf               # endpoint, CA, token, network name
    │
    ├── argocd/                      # ArgoCD installation
    │   ├── main.tf                  # Namespace + Helm release (argo-cd chart)
    │   ├── variables.tf             # namespace, chart_version, service_type
    │   ├── versions.tf              # Required providers
    │   └── outputs.tf               # server URL, namespace
    │
    ├── managed-db/                  # Cloud-managed databases
    │   ├── rds.tf                   # AWS RDS PostgreSQL 16 + ElastiCache Redis 7
    │   ├── azure_db.tf              # Azure DB for PostgreSQL + Azure Cache for Redis
    │   ├── cloudsql.tf              # Cloud SQL PostgreSQL 16 + Memorystore Redis 7
    │   ├── variables.tf             # DB size, credentials, cloud-specific networking
    │   ├── versions.tf              # Required providers
    │   └── outputs.tf               # database_url, redis_url, endpoints
    │
    └── connectk-app/                # ConnectK application deployment
        ├── secrets.tf               # K8s namespace + backend-secrets + postgres-credentials
        ├── argocd_deploy.tf         # AppProject + ApplicationSet (when ArgoCD available)
        ├── direct_deploy.tf         # kubectl apply -k fallback (when no ArgoCD)
        ├── variables.tf             # All app secrets and deployment config
        ├── versions.tf              # Required providers
        └── outputs.tf               # namespace, deployment_method
```

## Configuration Reference

### Deployment Flags

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `create_cluster` | bool | `true` | Create a new K8s cluster |
| `install_argocd` | bool | `true` | Install ArgoCD on the cluster |
| `cloud_provider` | string | - | `eks`, `aks`, or `gke` |
| `db_strategy` | string | `self-hosted` | `self-hosted` or `managed` |

### General

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `project_name` | string | `connectk` | Prefix for all resource names |
| `environment` | string | `prod` | Environment name |
| `domain_name` | string | `""` | Custom domain (empty = use LB DNS) |

### EKS-Specific

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `aws_region` | string | `us-east-1` | AWS region |
| `eks_cluster_version` | string | `1.31` | Kubernetes version |
| `eks_node_instance_types` | list(string) | `["t3.medium"]` | Node instance types |
| `eks_node_desired_size` | number | `3` | Desired node count |
| `eks_use_auto_mode` | bool | `false` | Use EKS Auto Mode |
| `vpc_cidr` | string | `10.0.0.0/16` | VPC CIDR block |

### AKS-Specific

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `azure_location` | string | `eastus` | Azure region |
| `aks_cluster_version` | string | `1.31` | Kubernetes version |
| `aks_node_vm_size` | string | `Standard_D2s_v5` | Node VM size |
| `aks_node_count` | number | `3` | Initial node count |

### GKE-Specific

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `gcp_project` | string | `""` | GCP project ID |
| `gcp_region` | string | `us-central1` | GCP region |
| `gke_cluster_version` | string | `1.31` | Kubernetes version |
| `gke_machine_type` | string | `e2-standard-2` | Node machine type |

### Existing Cluster (when `create_cluster = false`)

| Variable | Type | Description |
|----------|------|-------------|
| `existing_cluster_name` | string | Name of the existing cluster |
| `existing_aks_resource_group` | string | AKS resource group name |
| `existing_gke_project` | string | GKE project ID |
| `existing_gke_region` | string | GKE region/zone |

### Application Secrets

| Variable | Type | Sensitive | Description |
|----------|------|:---------:|-------------|
| `azure_tenant_id` | string | yes | Entra ID tenant ID |
| `azure_client_id` | string | yes | Entra ID app client ID |
| `azure_client_secret` | string | yes | Entra ID client secret |
| `session_secret_key` | string | yes | Auto-generated if empty |
| `csrf_secret_key` | string | yes | Auto-generated if empty |
| `db_password` | string | yes | Auto-generated if empty |
| `git_ssh_private_key` | string | yes | Base64-encoded SSH key for GitOps |

## Outputs

| Output | Description |
|--------|-------------|
| `cluster_endpoint` | Kubernetes API server endpoint |
| `cluster_name` | Cluster name |
| `kubeconfig_command` | Command to configure kubectl |
| `app_url` | ConnectK application URL |
| `argocd_url` | ArgoCD server URL |
| `argocd_admin_password_command` | Command to retrieve ArgoCD admin password |
| `database_endpoint` | PostgreSQL endpoint |
| `redis_endpoint` | Redis endpoint |
| `deployment_method` | How ConnectK was deployed (argocd/direct) |
| `vpc_id` | VPC/VNet ID |

## Example Configurations

### Greenfield EKS with self-hosted databases

```hcl
create_cluster = true
install_argocd = true
cloud_provider = "eks"
db_strategy    = "self-hosted"

aws_region              = "us-east-1"
eks_node_instance_types = ["t3.medium"]
eks_node_desired_size   = 3

azure_tenant_id     = "c4a1e262-..."
azure_client_id     = "2f16517f-..."
azure_client_secret = "83G8Q~..."
```

```bash
terraform init
terraform apply -target=module.eks
terraform apply
```

### Existing AKS cluster with managed databases

```hcl
create_cluster = false
install_argocd = true
cloud_provider = "aks"
db_strategy    = "managed"

existing_cluster_name       = "my-aks-cluster"
existing_aks_resource_group = "my-resource-group"
azure_location              = "eastus"

azure_tenant_id     = "c4a1e262-..."
azure_client_id     = "2f16517f-..."
azure_client_secret = "83G8Q~..."
```

```bash
terraform init
terraform apply
```

### Existing GKE cluster with ArgoCD already installed

```hcl
create_cluster = false
install_argocd = false
cloud_provider = "gke"
db_strategy    = "self-hosted"

existing_cluster_name = "my-gke-cluster"
existing_gke_project  = "my-project-123"
existing_gke_region   = "us-central1"
gcp_project           = "my-project-123"

argocd_server_url = "https://argocd.internal.example.com"

azure_tenant_id     = "c4a1e262-..."
azure_client_id     = "2f16517f-..."
azure_client_secret = "83G8Q~..."
```

```bash
terraform init
terraform apply
```

### EKS Auto Mode

```hcl
create_cluster = true
install_argocd = true
cloud_provider = "eks"
db_strategy    = "self-hosted"

eks_use_auto_mode = true  # No managed node group, EBS CSI, or ALB controller needed

azure_tenant_id     = "c4a1e262-..."
azure_client_id     = "2f16517f-..."
azure_client_secret = "83G8Q~..."
```

## How It Works

### Secret Management

Terraform manages sensitive secrets (database credentials, Azure Entra creds, session keys) as Kubernetes Secrets. ArgoCD manages everything else (Deployments, Services, ConfigMaps). The ApplicationSet uses `ignoreDifferences` on Secret resources to prevent ArgoCD from overwriting Terraform-managed secrets.

Auto-generated secrets:
- `session_secret_key` -- 64-char random string
- `csrf_secret_key` -- 64-char random string
- `db_password` -- 32-char random string (when `db_strategy = "self-hosted"`)

### ArgoCD Integration

When ArgoCD is available (`install_argocd = true` or `argocd_server_url` is set), Terraform creates:
1. **AppProject** `connectk` -- scoped to the `connectk` namespace
2. **ApplicationSet** -- uses a list generator with `cloud_provider` and `db_strategy` to sync the correct kustomize overlay from `k8s/overlays/{cloud}/{strategy}/`

When ArgoCD is NOT available, Terraform falls back to `kubectl apply -k` using the same kustomize overlay path.

### Cloud-Specific Details

**EKS:**
- VPC with 3-AZ public/private subnets, single NAT Gateway
- IRSA roles for EBS CSI Driver and ALB Controller
- EKS add-ons: vpc-cni, coredns, kube-proxy, aws-ebs-csi-driver
- AWS Load Balancer Controller via Helm (ALB Ingress)
- Optional: EKS Auto Mode (replaces managed node groups + add-ons)
- StorageClass: `connectk-ssd` (gp3, encrypted)

**AKS:**
- VNet with AKS subnet + DB-delegated subnet
- System-assigned managed identity
- NGINX Ingress Controller via Helm
- StorageClass: `connectk-ssd` (StandardSSD_LRS)

**GKE:**
- VPC with subnet + pod/service secondary IP ranges
- Cloud NAT for private node internet access
- Workload Identity enabled
- NGINX Ingress Controller via Helm
- StorageClass: `connectk-ssd` (pd-ssd)

## Destroy

```bash
# Remove the app first (avoids orphaned LBs)
terraform destroy -target=module.connectk_app
terraform destroy -target=module.argocd

# Then destroy infrastructure
terraform destroy
```

For GKE with managed DB, disable deletion protection first:

```bash
terraform apply -var="..." # set deletion_protection=false on Cloud SQL
terraform destroy
```

## Troubleshooting

### "kubernetes provider: no cluster endpoint"

This happens on greenfield deploys. Use the two-phase approach:

```bash
terraform apply -target=module.eks   # create cluster first
terraform apply                      # then deploy K8s resources
```

### ArgoCD sync fails on secrets

Terraform owns `backend-secrets` and `postgres-credentials`. If ArgoCD tries to overwrite them, ensure the ApplicationSet has `ignoreDifferences` for these secrets (already configured in `connectk-app/argocd_deploy.tf`).

### EKS pods stuck in Pending

Check that the EBS CSI driver is installed and the `connectk-ssd` StorageClass exists:

```bash
kubectl get sc connectk-ssd
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-ebs-csi-driver
```

### ALB not creating on EKS

Verify the AWS Load Balancer Controller is running:

```bash
kubectl get pods -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
kubectl logs -n kube-system -l app.kubernetes.io/name=aws-load-balancer-controller
```
