variable "cloud_provider" {
  description = "Cloud provider: eks, aks, or gke"
  type        = string

  validation {
    condition     = contains(["eks", "aks", "gke"], var.cloud_provider)
    error_message = "cloud_provider must be one of: eks, aks, gke"
  }
}

variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Instance class/size for the database (e.g., db.t3.medium for AWS)"
  type        = string
}

variable "db_storage_gb" {
  description = "Allocated storage in GB for the database"
  type        = number
}

variable "redis_node_type" {
  description = "Node type for the Redis cache (e.g., cache.t3.micro for AWS)"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# ──────────────────────────────────────────────
# AWS-specific variables
# ──────────────────────────────────────────────

variable "aws_vpc_id" {
  description = "AWS VPC ID for the database resources"
  type        = string
  default     = ""
}

variable "aws_private_subnet_ids" {
  description = "List of AWS private subnet IDs for database placement"
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = ""
}

# ──────────────────────────────────────────────
# Azure-specific variables
# ──────────────────────────────────────────────

variable "azure_resource_group_name" {
  description = "Azure resource group name"
  type        = string
  default     = ""
}

variable "azure_location" {
  description = "Azure location/region"
  type        = string
  default     = ""
}

variable "azure_subnet_id" {
  description = "Azure subnet ID for database private endpoints"
  type        = string
  default     = ""
}

# ──────────────────────────────────────────────
# GCP-specific variables
# ──────────────────────────────────────────────

variable "gcp_project" {
  description = "GCP project ID"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = ""
}

variable "gcp_network" {
  description = "GCP VPC network self-link or name"
  type        = string
  default     = ""
}
