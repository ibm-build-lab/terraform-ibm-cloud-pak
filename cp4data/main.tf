locals {
  ibm_operator_catalog = file(join("/", [path.module, "files", "ibm-operator-catalog.yaml"])) 
  opencloud_operator_catalog = file(join("/", [path.module, "files", "opencloud-operator-catalog.yaml"])) 
  subscription = file(join("/", [path.module, "files", "subscription.yaml"])) 
  operator_group = file(join("/", [path.module, "files", "operator-group.yaml"])) 
  cpd_service = file(join("/", [path.module, "files", "cpdservice.yaml"])) 
}

resource "null_resource" "install_cp4d" {
  count = var.enable ? 1 : 0

  triggers = {
    force_to_run                              = var.force ? timestamp() : 0
    namespace_sha1                            = sha1(local.namespace)
    docker_params_sha1                        = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    ibm_operator_catalog_sha1                 = sha1(local.ibm_operator_catalog)
    opencloud_operator_catalog_sha1           = sha1(local.opencloud_operator_catalog)
    subscription_sha1                         = sha1(local.subscription)
    operator_group_sha1                       = sha1(local.operator_group)
    cpd_service_sha1                          = sha1(local.cpd_service)
  }

  provisioner "local-exec" {
    command     = "./install_cp4d.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      FORCE                         = var.force
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = local.namespace
      IBM_OPERATOR_CATALOG          = local.ibm_operator_catalog
      OPENCLOUD_OPERATOR_CATALOG    = local.opencloud_operator_catalog
      SUBSCRIPTION                  = local.subscription
      DOCKER_REGISTRY_PASS          = local.entitled_registry_key
      DOCKER_USER_EMAIL             = var.entitled_registry_user_email
      DOCKER_USERNAME               = local.docker_username
      DOCKER_REGISTRY               = local.docker_registry
      OPERATOR_GROUP                = local.operator_group
      CPD_SERVICE                   = local.cpd_service

      // Modules to deploy
      install_watson_knowledge_catalog = var.install_watson_knowledge_catalog, // WKC
      install_watson_studio            = var.install_watson_studio,            // WSL
      install_watson_machine_learning  = var.install_watson_machine_learning,  // WML
      install_watson_open_scale        = var.install_watson_open_scale,        // AIOPENSCALE
      install_data_virtualization      = var.install_data_virtualization,      // DV
      install_streams                  = var.install_streams,                  // STREAMS
      install_analytics_dashboard      = var.install_analytics_dashboard,      // CDE
      install_spark                    = var.install_spark,                    // SPARK
      install_db2_warehouse            = var.install_db2_warehouse,            // DB2WH
      install_db2_data_gate            = var.install_db2_data_gate,            // DATAGATE
      install_rstudio                  = var.install_rstudio,                  // RSTUDIO
      install_db2_data_management      = var.install_db2_data_management,      // DMC

      // DEBUG                    = true
    }
  }
}

# data "external" "get_endpoints" {
#   count = var.enable ? 1 : 0

#   depends_on = [
#     null_resource.install_cp4d,
#   ]

#   program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

#   query = {
#     kubeconfig = var.cluster_config_path
#     namespace  = local.namespace
#   }
# }

// TODO: It may be considered in a future version to pass the cluster ID and the
// resource group to get the cluster configuration and store it in memory and in
// a directory, either specified by the user or in the module local directory

// variable "resource_group" {
//   default     = "default"
//   description = "List all available resource groups with: ibmcloud resource groups"
// }
// data "ibm_resource_group" "group" {
//   name = var.resource_group
// }
// data "ibm_container_cluster_config" "cluster_config" {
//   cluster_name_id   = var.cluster_id
//   resource_group_id = data.ibm_resource_group.group.id
// }
