# ──────────────────────────────────────────────
# AWS RDS (PostgreSQL) + ElastiCache (Redis)
# Only created when cloud_provider == "eks"
# ──────────────────────────────────────────────

data "aws_vpc" "selected" {
  count = var.cloud_provider == "eks" ? 1 : 0
  id    = var.aws_vpc_id
}

# ── RDS Subnet Group ────────────────────────

resource "aws_db_subnet_group" "postgres" {
  count      = var.cloud_provider == "eks" ? 1 : 0
  name       = "${var.name_prefix}-postgres-subnet-group"
  subnet_ids = var.aws_private_subnet_ids

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-postgres-subnet-group"
  })
}

# ── RDS Security Group ──────────────────────

resource "aws_security_group" "rds" {
  count       = var.cloud_provider == "eks" ? 1 : 0
  name        = "${var.name_prefix}-rds-sg"
  description = "Allow PostgreSQL access from within the VPC"
  vpc_id      = var.aws_vpc_id

  ingress {
    description = "PostgreSQL from VPC CIDR"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected[0].cidr_block]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-rds-sg"
  })
}

# ── RDS PostgreSQL Instance ─────────────────

resource "aws_db_instance" "postgres" {
  count = var.cloud_provider == "eks" ? 1 : 0

  identifier = "${var.name_prefix}-postgres"

  engine         = "postgres"
  engine_version = "16"
  instance_class = var.db_instance_class

  allocated_storage     = var.db_storage_gb
  max_allocated_storage = var.db_storage_gb * 2
  storage_type          = "gp3"
  storage_encrypted     = true

  db_name  = "connectk"
  username = var.db_username
  password = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.postgres[0].name
  vpc_security_group_ids = [aws_security_group.rds[0].id]

  multi_az            = false
  publicly_accessible = false

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:30-sun:05:30"

  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.name_prefix}-postgres-final"

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-postgres"
  })
}

# ── ElastiCache Subnet Group ────────────────

resource "aws_elasticache_subnet_group" "redis" {
  count      = var.cloud_provider == "eks" ? 1 : 0
  name       = "${var.name_prefix}-redis-subnet-group"
  subnet_ids = var.aws_private_subnet_ids
}

# ── ElastiCache Security Group ──────────────

resource "aws_security_group" "redis" {
  count       = var.cloud_provider == "eks" ? 1 : 0
  name        = "${var.name_prefix}-redis-sg"
  description = "Allow Redis access from within the VPC"
  vpc_id      = var.aws_vpc_id

  ingress {
    description = "Redis from VPC CIDR"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [data.aws_vpc.selected[0].cidr_block]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-redis-sg"
  })
}

# ── ElastiCache Redis Cluster ────────────────

resource "aws_elasticache_cluster" "redis" {
  count = var.cloud_provider == "eks" ? 1 : 0

  cluster_id      = "${var.name_prefix}-redis"
  engine          = "redis"
  engine_version  = "7.1"
  node_type       = var.redis_node_type
  num_cache_nodes = 1
  port            = 6379

  subnet_group_name  = aws_elasticache_subnet_group.redis[0].name
  security_group_ids = [aws_security_group.redis[0].id]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}-redis"
  })
}
