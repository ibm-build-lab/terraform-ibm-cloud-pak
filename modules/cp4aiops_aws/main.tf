locals {
  # These are the the yamls that will be pulled from the ./files  these will be used to start hte operator
  cp4aiops_subscription = file(join("/", [path.module, "files", "aiops-subscription.yaml"]))
  cp4aiops_service      = file(join("/", [path.module, "files", "cp-aiops-service.yaml"]))

}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_cp4aiops" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1        = sha1(var.namespace)
    cp4aiops_sha1         = sha1(local.cp4aiops_subscription)
    cp4aiops_service_sha1 = sha1(local.cp4aiops_service)
  }

  provisioner "local-exec" {
    command     = "./install_cp4aiops.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      KUBECONFIG = var.cluster_config_path
      NAMESPACE  = var.namespace
      ON_VPC     = var.on_vpc

      CP4AIOPS_SUB         = local.cp4aiops_subscription
      CP4AIOPS_SERVICE     = local.cp4aiops_service
      DOCKER_REGISTRY_PASS = var.entitled_registry_key
      DOCKER_USER_EMAIL    = var.entitled_registry_user_email
      DOCKER_USERNAME      = local.docker_username
      DOCKER_REGISTRY      = local.docker_registry
    }
  }

  depends_on = [
    null_resource.prereqs_checkpoint
  ]
}

data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_cp4aiops
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.namespace
  }
}
