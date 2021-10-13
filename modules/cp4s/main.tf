locals {

  # These are the the yamls that will be pulled from the ./files  these will be used to start hte operator
  operator_catalog = file(join("/", [path.module, "files", "operator-catalog.yaml"])) 
  common_services_catalog = file(join("/", [path.module, "files", "common-services.yaml"])) 
  operator_group = file(join("/", [path.module, "files", "operator-group.yaml"])) 
  subscription = file(join("/", [path.module, "files", "subscription.yaml"]))
  cp4s_threat_management = file(join("/", [path.module, "files", "cp4s-threat-management.yaml"])) 

}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_cp4s" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1                            = sha1(local.namespace)
    docker_params_sha1                        = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    operator_catalog_sha1                     = sha1(local.operator_catalog)
    common_services_catalog_sha1              = sha1(local.common_services_catalog)
    operator_group_sha1                       = sha1(local.operator_group)
    subscription_sha1                         = sha1(local.subscription)
    cp4s_threat_management_sha1               = sha1(local.cp4s_threat_management)
  }

  provisioner "local-exec" {
    command     = "./install_cp4s.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = local.namespace
      
      OPERATOR_GROUP                = local.operator_group
      SUBSCRIPTION                  = local.subscription
      OPERATOR_CATALOG              = local.operator_catalog
      COMMON_SERVICES_CATALOG       = local.common_services_catalog
      DOCKER_REGISTRY_PASS          = var.entitled_registry_key
      DOCKER_USER_EMAIL             = var.entitled_registry_user_email
      DOCKER_USERNAME               = local.docker_username
      DOCKER_REGISTRY               = local.docker_registry
      CP4S_THREAT_MANAGEMENT        = local.cp4s_threat_management
    }
  }
}
