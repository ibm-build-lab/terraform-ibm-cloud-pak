provider "kubernetes" {
  version            = "~> 1.13"
  load_config_file   = false
  host               = module.cluster.config.host
  client_certificate = module.cluster.config.admin_certificate
  client_key         = module.cluster.config.admin_key
  token              = module.cluster.config.token
}

locals {
  namespace = "terraform-module-is-working"
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = local.namespace
  }
}

data "external" "kubectl_namespace" {
  count = length(var.config_dir) > 0 ? 1 : 0
  depends_on = [
    kubernetes_namespace.namespace,
  ]

  program = ["sh", "-c", "echo \"{ \\\"namespace\\\": \\\"$(kubectl --kubeconfig ${module.cluster.config.config_file_path} get namespace ${local.namespace} -o jsonpath='{.metadata.name}')\\\" }\""]
}

output "namespace" {
  value = length(var.config_dir) > 0 ? data.external.kubectl_namespace.0.result.namespace : ""
}
