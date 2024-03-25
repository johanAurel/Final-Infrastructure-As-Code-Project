variable "vpc_name" {
  description = "Name of the VPC to place cluster in"
  type        = string
  default     = "project-vpc"
}

variable "cluster_name" {
  description = "Name you wish to give to your EKS cluster"
  type        = string
  default     = "project-cluster"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "frontend_repo_name" {
  type = string
  default = "frontend-project"
}

variable "backend_repo_name" {
  type = string
  default = "backend-project"
}