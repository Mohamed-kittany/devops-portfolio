variable "project_name" {
  type        = string
}

variable "environment" {
  type        = string
}

variable "cluster_name" {
  type        = string
}

variable "oidc_issuer" {
  description = "OIDC issuer URL"
  type        = string
}

variable "tags" {
  type        = map(string)
  default     = {}
}