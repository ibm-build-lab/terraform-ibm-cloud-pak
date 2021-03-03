locals {

  # These are the the yamls that will be pulled from the ./files  these will be used to start hte operator
  ibm_operator_catalog = file(join("/", [path.module, "files", "ibm-operator-catalog.yaml"])) 
  opencloud_operator_catalog = file(join("/", [path.module, "files", "opencloud-operator-catalog.yaml"])) 
  subscription = file(join("/", [path.module, "files", "subscription.yaml"])) 
  platform_navigator = file(join("/", [path.module, "files", "navigator.yaml"]))
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_cp4i" {
  count = var.enable ? 1 : 0

  triggers = {
    force_to_run                              = var.force ? timestamp() : 0
    namespace_sha1                            = sha1(local.namespace)
    docker_params_sha1                        = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    ibm_operator_catalog_sha1                 = sha1(local.ibm_operator_catalog)
    opencloud_operator_catalog_sha1           = sha1(local.opencloud_operator_catalog)
    subscription_sha1                         = sha1(local.subscription)
    platform_navigator_sha1                   = sha1(local.platform_navigator)
  }

  provisioner "local-exec" {
    command     = "./install_cp4i.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      FORCE                         = var.force
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = local.namespace
      IBM_OPERATOR_CATALOG          = local.ibm_operator_catalog
      OPENCLOUD_OPERATOR_CATALOG    = local.opencloud_operator_catalog
      SUBSCRIPTION                  = local.subscription
      PLATFORM_NAVIGATOR            = local.platform_navigator
      DOCKER_REGISTRY_PASS          = local.entitled_registry_key
      DOCKER_USER_EMAIL             = var.entitled_registry_user_email
      DOCKER_USERNAME               = local.docker_username
      DOCKER_REGISTRY               = local.docker_registry
    }
  }
}
