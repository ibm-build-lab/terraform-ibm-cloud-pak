locals {
  # These are the the yamls that will be pulled from the ./files  these will be used to start hte operator
  ibm_operator_catalog       = file(join("/", [path.module, "files", "ibm-operator-catalog.yaml"])) 
  opencloud_operator_catalog = file(join("/", [path.module, "files", "opencloud-operator-catalog.yaml"])) 
  subscription               = file(join("/", [path.module, "files", "subscription.yaml"])) 

  on_vpc_ready = var.on_vpc ? var.portworx_is_ready : 1
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_cp4i" {
  count = var.enable ? 1 : 0

  triggers = {
    force_to_run                              = var.force ? timestamp() : 0
    namespace_sha1                            = sha1(var.namespace)
    docker_params_sha1                        = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    ibm_operator_catalog_sha1                 = sha1(local.ibm_operator_catalog)
    opencloud_operator_catalog_sha1           = sha1(local.opencloud_operator_catalog)
    subscription_sha1                         = sha1(local.subscription)
  }

  provisioner "local-exec" {
    command     = "./install_cp4i.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      FORCE                         = var.force
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.namespace
      ON_VPC                        = var.on_vpc
      IBM_OPERATOR_CATALOG          = local.ibm_operator_catalog
      OPENCLOUD_OPERATOR_CATALOG    = local.opencloud_operator_catalog
      SUBSCRIPTION                  = local.subscription
      DOCKER_REGISTRY_PASS          = local.entitled_registry_key
      DOCKER_USER_EMAIL             = var.entitled_registry_user_email
      DOCKER_USERNAME               = local.entitled_registry_user
      DOCKER_REGISTRY               = local.entitled_registry
    }
  }

  depends_on = [
    local.on_vpc_ready
  ]
}

data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_cp4i
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.namespace
  }
}
