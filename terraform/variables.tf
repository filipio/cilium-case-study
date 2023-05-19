variable "cluster_name" {
  type    = string
  default = "my-awesome-cluster"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "node_group_instance_type" {
  type    = string
  default = "t2.small"
}