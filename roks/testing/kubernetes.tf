data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = local.enable ? module.cluster.id : var.cluster_id
  resource_group_id = module.cluster.resource_group.id
  config_dir        = var.config_dir
}


provider "kubernetes" {
  load_config_file   = false
  host               = data.ibm_container_cluster_config.cluster_config.host
  client_certificate = data.ibm_container_cluster_config.cluster_config.admin_certificate
  client_key         = data.ibm_container_cluster_config.cluster_config.admin_key
  token              = data.ibm_container_cluster_config.cluster_config.token
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
  count = length(var.config_dir) != 0 ? 1 : 0
  depends_on = [
    kubernetes_namespace.namespace,
  ]

  program = ["sh", "-c", "echo \"{ \\\"namespace\\\": \\\"$(kubectl --kubeconfig ${data.ibm_container_cluster_config.cluster_config.config_file_path} get namespace ${local.namespace} -o jsonpath='{.metadata.name}')\\\" }\""]
}

output "namespace" {
  value = length(var.config_dir) > 0 ? data.external.kubectl_namespace.0.result.namespace : ""
}
