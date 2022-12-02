locals {
  # These are the the yamls that will be pulled from the ./files  these will be used to start the operator
  operator_catalog        = file(join("/", [path.module, "files", "operator-catalog.yaml"]))
  common_services_catalog = file(join("/", [path.module, "files", "common-services.yaml"]))
  redis_catalog           = file(join("/", [path.module, "files", "redis-catalog.yaml"]))
  service_account         = file(join("/", [path.module, "files", "service-account.yaml"]))
  operator_group          = file(join("/", [path.module, "files", "operator-group.yaml"]))
  subscription            = file(join("/", [path.module, "files", "subscription.yaml"]))
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_cp4na" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1               = sha1(var.namespace)
    docker_params_sha1           = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    operator_catalog_sha1        = sha1(local.operator_catalog)
    common_services_catalog_sha1 = sha1(local.common_services_catalog)
    redis_catalog_sha1           = sha1(local.redis_catalog)
    service_account_sha1         = sha1(local.service_account)
    operator_group_sha1          = sha1(local.operator_group)
    subscription_sha1            = sha1(local.subscription)
  }

  provisioner "local-exec" {
    command     = "./install_cp4na.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      KUBECONFIG = var.cluster_config_path
      NAMESPACE  = var.namespace

      OPERATOR_GROUP          = local.operator_group
      SUBSCRIPTION            = local.subscription
      OPERATOR_CATALOG        = local.operator_catalog
      COMMON_SERVICES_CATALOG = local.common_services_catalog
      REDIS_CATALOG           = local.redis_catalog
      SERVICE_ACCOUNT         = local.service_account
      DOCKER_REGISTRY_PASS    = var.entitled_registry_key
      DOCKER_USER_EMAIL       = var.entitled_registry_user_email
      DOCKER_USERNAME         = local.docker_username
      DOCKER_REGISTRY         = local.docker_registry
    }
  }
}
