# ConnectK App Module

Deploys the ConnectK application. Creates Kubernetes secrets and deploys via ArgoCD or direct `kubectl apply`.

## What It Creates

### Always created:
- **Namespace**: `connectk`
- **Secret `backend-secrets`**: All application secrets (DB URLs, Azure creds, session keys, ArgoCD URL)
- **Secret `postgres-credentials`**: PostgreSQL user/password (only when `db_strategy = "self-hosted"`)

### When ArgoCD is available (`use_argocd = true`):
- **AppProject `connectk`**: Scoped to connectk namespace, allows core K8s + networking resources
- **ApplicationSet `connectk`**: List generator with cloud/strategy, syncs from `k8s/overlays/{cloud}/{strategy}/`
- Auto-sync with prune + self-heal enabled
- `ignoreDifferences` on Secret resources (prevents ArgoCD from overwriting Terraform-managed secrets)

### When ArgoCD is NOT available (`use_argocd = false`):
- **Direct deploy**: `kubectl apply -k k8s/overlays/{cloud}/{strategy}/`
- Triggers on image tag, db_strategy, or cloud_provider changes

## Secret Ownership Split

| Owner | Resources |
|-------|-----------|
| **Terraform** | `backend-secrets`, `postgres-credentials` |
| **ArgoCD / kubectl** | Deployments, Services, ConfigMaps, Ingress, StatefulSets, HPAs |

The ApplicationSet's `ignoreDifferences` ensures ArgoCD never overwrites secrets that Terraform manages.

## Inputs

| Variable | Type | Sensitive | Description |
|----------|------|:---------:|-------------|
| `use_argocd` | bool | | Deploy via ArgoCD or kubectl |
| `cloud_provider` | string | | `eks`, `aks`, `gke` |
| `db_strategy` | string | | `self-hosted` or `managed` |
| `database_url` | string | yes | Async DB URL |
| `database_sync_url` | string | yes | Sync DB URL |
| `redis_url` | string | yes | Redis URL |
| `azure_tenant_id` | string | yes | Entra ID tenant |
| `azure_client_id` | string | yes | Entra ID client |
| `azure_client_secret` | string | yes | Entra ID secret |
| `session_secret_key` | string | yes | Session encryption key |
| `csrf_secret_key` | string | yes | CSRF token key |
| `git_ssh_private_key` | string | yes | SSH key for GitOps |
| `argocd_server_url` | string | | ArgoCD server URL |
| `self_hosted_db_password` | string | yes | Postgres password |
| `git_repo_url` | string | | ArgoCD source repo |
| `git_repo_branch` | string | | Git branch to track |
| `container_registry` | string | | Container registry |
| `backend_image_tag` | string | | Backend image tag |
| `frontend_image_tag` | string | | Frontend image tag |
| `domain_name` | string | | Application domain |

## Outputs

| Output | Description |
|--------|-------------|
| `app_namespace` | Kubernetes namespace (`connectk`) |
| `deployment_method` | `argocd` or `direct` |
