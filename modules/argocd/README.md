# ArgoCD Module

Installs ArgoCD on the Kubernetes cluster using the official Helm chart.

## What It Creates

- **Namespace**: Dedicated namespace (default: `argocd`)
- **Helm Release**: ArgoCD from `https://argoproj.github.io/argo-helm` chart `argo-cd`
- Server runs in insecure mode (TLS termination at ingress/LB level)
- ApplicationSet controller enabled

## Configuration

The server service type defaults to `LoadBalancer`. Set to `ClusterIP` if you want to access ArgoCD only through an ingress or port-forward.

## Getting the Admin Password

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

## Inputs

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `namespace` | string | `argocd` | K8s namespace |
| `chart_version` | string | `7.7.10` | Helm chart version |
| `server_service_type` | string | `LoadBalancer` | Server service type |
| `cloud_provider` | string | - | Cloud provider name |
| `git_repo_url` | string | connectk repo | Git repo for ArgoCD |

## Outputs

| Output | Description |
|--------|-------------|
| `argocd_server_url` | Internal server URL (`https://argocd-server.<ns>.svc.cluster.local`) |
| `argocd_namespace` | Installed namespace |
