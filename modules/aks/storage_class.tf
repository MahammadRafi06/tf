# ─────────────────────────────────────────────────
# StorageClass for ConnectK persistent volumes
# Azure Disk CSI driver (pre-installed on AKS 1.21+)
# ─────────────────────────────────────────────────

resource "kubernetes_storage_class" "connectk_ssd" {
  metadata {
    name = "connectk-ssd"
    labels = {
      "app.kubernetes.io/part-of" = "connectk"
    }
  }

  storage_provisioner    = "disk.csi.azure.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  reclaim_policy         = "Retain"

  parameters = {
    skuName = "StandardSSD_LRS"
  }

  depends_on = [azurerm_kubernetes_cluster.this]
}
