# ─────────────────────────────────────────────────
# EKS Cluster
# ─────────────────────────────────────────────────

resource "aws_eks_cluster" "this" {
  name     = var.name_prefix
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = concat(aws_subnet.public[*].id, aws_subnet.private[*].id)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  dynamic "compute_config" {
    for_each = var.use_auto_mode ? [1] : []
    content {
      enabled       = true
      node_pools    = ["general-purpose"]
      node_role_arn = aws_iam_role.cluster.arn
    }
  }

  dynamic "kubernetes_network_config" {
    for_each = var.use_auto_mode ? [1] : []
    content {
      elastic_load_balancing {
        enabled = true
      }
    }
  }

  dynamic "storage_config" {
    for_each = var.use_auto_mode ? [1] : []
    content {
      block_storage {
        enabled = true
      }
    }
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.cluster_vpc_controller,
  ]
}

# ─────────────────────────────────────────────────
# Managed Node Group (when NOT using Auto Mode)
# ─────────────────────────────────────────────────

resource "aws_eks_node_group" "default" {
  count = var.use_auto_mode ? 0 : 1

  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.name_prefix}-default"
  node_role_arn   = aws_iam_role.node_group[0].arn
  subnet_ids      = aws_subnet.private[*].id
  instance_types  = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    min_size     = var.node_min_size
    max_size     = var.node_max_size
  }

  update_config {
    max_unavailable = 1
  }

  tags = var.tags

  depends_on = [
    aws_iam_role_policy_attachment.node_worker,
    aws_iam_role_policy_attachment.node_cni,
    aws_iam_role_policy_attachment.node_ecr,
  ]
}

# ─────────────────────────────────────────────────
# Auth token for Kubernetes provider
# ─────────────────────────────────────────────────

data "aws_eks_cluster_auth" "this" {
  name = aws_eks_cluster.this.name
}
