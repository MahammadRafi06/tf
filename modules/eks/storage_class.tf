# ─────────────────────────────────────────────────
# StorageClass for ConnectK persistent volumes
# Uses EKS Auto Mode provisioner when auto_mode is
# enabled, otherwise standard EBS CSI.
# ─────────────────────────────────────────────────

resource "kubernetes_storage_class" "connectk_ssd" {
  metadata {
    name = "connectk-ssd"
    labels = {
      "app.kubernetes.io/part-of" = "connectk"
    }
  }

  storage_provisioner    = var.use_auto_mode ? "ebs.csi.eks.amazonaws.com" : "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  allow_volume_expansion = true
  reclaim_policy         = "Retain"

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  depends_on = [aws_eks_cluster.this]
}
