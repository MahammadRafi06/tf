output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  value = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
}

output "cluster_token" {
  value     = data.aws_eks_cluster_auth.this.token
  sensitive = true
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "oidc_provider_arn" {
  value = local.oidc_provider_arn
}

output "acm_certificate_arn" {
  value = var.domain_name != "" ? aws_acm_certificate.this[0].arn : ""
}
