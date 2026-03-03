# ─────────────────────────────────────────────────
# StorageClass for ConnectK persistent volumes
# GKE PD CSI driver (pre-installed on GKE 1.18+)
# ─────────────────────────────────────────────────

resource "kubernetes_storage_class" "connectk_ssd" {
  metadata {
    name = "connectk-ssd"
    labels = {
      "app.kubernetes.io/part-of" = "connectk"
    }
  }

  storage_provisioner    = "pd.csi.storage.gke.io"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  reclaim_policy         = "Retain"

  parameters = {
    type = "pd-ssd"
  }

  depends_on = [google_container_cluster.this]
}
