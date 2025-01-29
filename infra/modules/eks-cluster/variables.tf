variable "project_name" {
  type        = string
}

variable "environment" {
  type        = string
}

variable "cluster_name" {
  type        = string
}

variable "eks_version" {
  type        = string
}

variable "tags" {
  type        = map(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs for the EKS cluster"
  type        = list(string)
}