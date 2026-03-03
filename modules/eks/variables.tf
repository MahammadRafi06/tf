variable "name_prefix" {
  type = string
}

variable "cluster_version" {
  type    = string
  default = "1.31"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "node_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_desired_size" {
  type    = number
  default = 3
}

variable "node_min_size" {
  type    = number
  default = 2
}

variable "node_max_size" {
  type    = number
  default = 5
}

variable "use_auto_mode" {
  type    = bool
  default = false
}

variable "domain_name" {
  type    = string
  default = ""
}

variable "tags" {
  type    = map(string)
  default = {}
}
