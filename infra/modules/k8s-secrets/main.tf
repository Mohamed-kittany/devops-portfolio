locals {
  secrets_map = {
    for secret_id, secret in data.aws_secretsmanager_secret_version.secrets :
    secret_id => {
      for key, value in jsondecode(secret.secret_string) :
      key => base64decode(value) # Decode pre-encoded values
    }
  }
}

# Retrieve secrets from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "secrets" {
  for_each = { for secret in var.k8s_secrets_config : secret.secret_id => secret }

  secret_id = each.value.secret_id
}

resource "kubernetes_namespace" "namespace" {
  for_each = toset([for ns in var.k8s_secrets_config : ns.namespace_name])

  metadata {
    name = each.key
  }

}

resource "kubernetes_secret" "todoapp" {
  for_each = { for config in var.k8s_secrets_config : config.kb8_secret_file_name => config }

  metadata {
    name      = each.value.kb8_secret_file_name
    namespace = kubernetes_namespace.namespace[each.value.namespace_name].metadata[0].name
  }

  data = {
    for key, value in local.secrets_map[each.value.secret_id] :
    key => value
  }

  depends_on = [ kubernetes_namespace.namespace ]
  type = "Opaque"
}
