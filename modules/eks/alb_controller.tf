# ─────────────────────────────────────────────────
# AWS Load Balancer Controller (via Helm)
# Required for ALB Ingress on EKS.
# Skipped in Auto Mode (ELB is built in).
# ─────────────────────────────────────────────────

resource "helm_release" "alb_controller" {
  count = var.use_auto_mode ? 0 : 1

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.11.0"

  set {
    name  = "clusterName"
    value = aws_eks_cluster.this.name
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.alb_controller.arn
  }

  set {
    name  = "region"
    value = data.aws_region.current.name
  }

  set {
    name  = "vpcId"
    value = aws_vpc.this.id
  }

  depends_on = [
    aws_eks_node_group.default,
    aws_iam_role_policy_attachment.alb_controller,
  ]
}

data "aws_region" "current" {}
