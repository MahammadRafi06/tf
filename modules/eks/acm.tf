# ─────────────────────────────────────────────────
# ACM Certificate (only when domain_name is set)
# ─────────────────────────────────────────────────

resource "aws_acm_certificate" "this" {
  count = var.domain_name != "" ? 1 : 0

  domain_name       = var.domain_name
  validation_method = "DNS"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-cert"
  })

  lifecycle {
    create_before_destroy = true
  }
}
