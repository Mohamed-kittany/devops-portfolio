variable "k8s_secrets_config" {
  description = "List of Kubernetes secret configurations"
  type = list(object({
    secret_id           = string
    namespace_name      = string
    kb8_secret_file_name = string
  }))
}
