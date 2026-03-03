variable "name_prefix" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "cluster_version" {
  type    = string
  default = "1.31"
}

variable "machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "node_count" {
  type    = number
  default = 1
}

variable "min_node_count" {
  type    = number
  default = 1
}

variable "max_node_count" {
  type    = number
  default = 3
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/20"
}

variable "tags" {
  type    = map(string)
  default = {}
}
