locals {
  # These are the the yamls that will be pulled from the ./files  these will be used to start hte operator
  cp4aiops_subscription = file(join("/", [path.module, "files", "aiops-subscription.yaml"])) 

  on_vpc_ready = var.on_vpc ? var.portworx_is_ready : 1
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_cp4aiops" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1                      = sha1(var.namespace)
    docker_params_sha1                  = sha1(join("", [var.entitled_registry_user, local.entitled_registry_key]))
    cp4aiops_sha1                       = sha1(local.cp4aiops_subscription)
  }

  provisioner "local-exec" {
    command     = "./install_cp4aiops.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.namespace
      ON_VPC                        = var.on_vpc
      IC_API_KEY                    = var.ibmcloud_api_key
      CP4WAIOPS                     = local.cp4aiops_subscription
      DOCKER_REGISTRY_PASS          = var.entitlement_key
      DOCKER_USER_EMAIL             = var.entitled_registry_user
      DOCKER_USERNAME               = local.docker_username
      DOCKER_REGISTRY               = local.docker_registry

//      entitlement_key = var.entitlement_key
    }
  }

  depends_on = [
    local.on_vpc_ready,
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
