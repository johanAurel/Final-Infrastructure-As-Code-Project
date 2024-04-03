variable "cluster_name" {
  description = "The name of the EKS cluster - used for identifying network aspects with tags"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to place the cluster id"
  type        = string
}

variable "private_subnets" {
  description = "Private Subnet IDs for the cluster"
  type        = list(string)
}

variable "desired_size" {
  type = number
  default = 3
}

variable "min_size" {
  type = number
  default = 2
}

variable "max_size" {
  type = number
  default = 4
}

variable "node_group_name" {
  type = string
  default = "node-group-1"
}

variable "instance_types" {
  type = list(string)
  default = [ "t3.small" ]
}