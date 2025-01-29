variable "project_name" {
  type        = string
}

variable "environment" {
  type        = string
}

variable "cluster_name" {
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the Node Group"
  type        = list(string)
}

variable "desired_size" {
  description = "Desired number of nodes in the Node Group"
  type        = number
}

variable "max_size" {
  description = "Maximum number of nodes in the Node Group"
  type        = number
}

variable "min_size" {
  description = "Minimum number of nodes in the Node Group"
  type        = number
}

variable "instance_types" {
  description = "List of instance types for the Node Group"
  type        = list(string)
}

variable "tags" {
  type        = map(string)
}
