# ──────────────────────────────────────────────
# ArgoCD-based deployment
# Only created when use_argocd == true
# ──────────────────────────────────────────────

# ── ArgoCD AppProject ────────────────────────

resource "kubectl_manifest" "appproject" {
  count = var.use_argocd ? 1 : 0

  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: AppProject
    metadata:
      name: connectk
      namespace: argocd
    spec:
      description: ConnectK application project

      sourceRepos:
        - "${var.git_repo_url}"

      destinations:
        - namespace: connectk
          server: https://kubernetes.default.svc
          name: in-cluster

      clusterResourceWhitelist:
        - group: ""
          kind: Namespace
        - group: storage.k8s.io
          kind: StorageClass

      namespaceResourceWhitelist:
        - group: ""
          kind: "*"
        - group: apps
          kind: "*"
        - group: autoscaling
          kind: "*"
        - group: networking.k8s.io
          kind: Ingress
        - group: elbv2.k8s.aws
          kind: TargetGroupBinding
  YAML

  depends_on = [kubernetes_namespace.connectk]
}

# ── ArgoCD ApplicationSet ────────────────────

resource "kubectl_manifest" "applicationset" {
  count = var.use_argocd ? 1 : 0

  yaml_body = <<-YAML
    apiVersion: argoproj.io/v1alpha1
    kind: ApplicationSet
    metadata:
      name: connectk
      namespace: argocd
    spec:
      generators:
        - list:
            elements:
              - cloud: "${var.cloud_provider}"
                strategy: "${var.db_strategy}"

      template:
        metadata:
          name: "connectk-{{cloud}}-{{strategy}}"
          labels:
            app.kubernetes.io/part-of: connectk
            connectk/cloud: "{{cloud}}"
            connectk/strategy: "{{strategy}}"
        spec:
          project: connectk

          source:
            repoURL: "${var.git_repo_url}"
            targetRevision: "${var.git_repo_branch}"
            path: "k8s/overlays/{{cloud}}/{{strategy}}"

          destination:
            server: https://kubernetes.default.svc
            namespace: connectk

          syncPolicy:
            automated:
              prune: true
              selfHeal: true
            syncOptions:
              - CreateNamespace=true
              - PrunePropagationPolicy=foreground
              - PruneLast=true
            retry:
              limit: 3
              backoff:
                duration: 5s
                factor: 2
                maxDuration: 1m

          ignoreDifferences:
            - group: apps
              kind: Deployment
              jsonPointers:
                - /spec/replicas
            - group: ""
              kind: Secret
              name: backend-secrets
              jsonPointers:
                - /data
            - group: ""
              kind: Secret
              name: postgres-credentials
              jsonPointers:
                - /data
  YAML

  depends_on = [kubectl_manifest.appproject]
}
