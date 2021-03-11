locals {
  ibm_operator_catalog              = file(join("/", [path.module, "files", "ibm-operator-catalog.yaml"])) 
  opencloud_operator_catalog        = file(join("/", [path.module, "files", "opencloud-operator-catalog.yaml"])) 
  subscription                      = file(join("/", [path.module, "files", "subscription.yaml"])) 
  operator_group                    = file(join("/", [path.module, "files", "operator-group.yaml"])) 
  lite_service                      = file(join("/", [path.module, "files", "lite-service.yaml"])) 
  wkc_service                       = file(join("/", [path.module, "files", "wkc-service.yaml"]))
  wml_service                       = file(join("/", [path.module, "files", "wml-service.yaml"]))
  wos_service                       = file(join("/", [path.module, "files", "wos-service.yaml"]))
  wsl_service                       = file(join("/", [path.module, "files", "wsl-service.yaml"]))
  streams_service                   = file(join("/", [path.module, "files", "streams-service.yaml"]))
  spark_service                     = file(join("/", [path.module, "files", "spark-service.yaml"]))
  rstudio_service                   = file(join("/", [path.module, "files", "rstudio-service.yaml"]))
  dv_service                        = file(join("/", [path.module, "files", "dv-service.yaml"]))
  db2_warehouse_service             = file(join("/", [path.module, "files", "db2-warehouse_service.yaml"]))
  db2_data_mngmt_service            = file(join("/", [path.module, "files", "db2-data_mngmt_service.yaml"]))
  db2_data_gate_service             = file(join("/", [path.module, "files", "db2-data_gate_service.yaml"]))
  cde_service                       = file(join("/", [path.module, "files", "cde-service.yaml"]))
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
    lite_service_sha1                         = sha1(local.lite_service)
    wkc_service_sha1                          = sha1(local.wkc_service)
    wml_service_sha1                          = sha1(local.wml_service)
    wos_service_sha1                          = sha1(local.wos_service)
    wsl_service_sha1                          = sha1(local.wsl_service)
    streams_service_sha1                      = sha1(local.streams_service)
    spark_service_sha1                        = sha1(local.spark_service)
    rstudio_service_sha1                      = sha1(local.rstudio_service)
    dv_service_sha1                           = sha1(local.dv_service)
    db2_warehouse_service_sha1                = sha1(local.db2_warehouse_service)
    db2_data_mngmt_service_sha1               = sha1(local.db2_data_mngmt_service)
    db2_data_gate_service_sha1                = sha1(local.db2_data_gate_service)
    cde_service_sha1                          = sha1(local.cde_service)
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
      
      # CPD Service Modules
      LITE_SERVICE                  = local.lite_service
      WKC_SERVICE                   = local.wkc_service           
      WML_SERVICE                   = local.wml_service           
      WOS_SERVICE                   = local.wos_service           
      WSL_SERVICE                   = local.wsl_service            
      STREAMS_SERVICE               = local.streams_service       
      SPARK_SERVICE                 = local.spark_service         
      RSTUDIO_SERVICE               = local.rstudio_service       
      DV_SERVICE                    = local.dv_service             // data virtualization
      DB2_WAREHOUSE_SERVICE         = local.db2_warehouse_service       
      DB2_DATA_MNGMT_SERVICE        = local.db2_data_mngmt_service
      DB2_DATA_GATE_SERVICE         = local.db2_data_gate_service 
      CDE_SERVICE                   = local.cde_service            // Cognos Dashboard Embedded
      // DEBUG                    = true

      // Modules to deploy T/F
      EMPTY_MODULE_LIST                = var.empty_module_list // Used to determine default array in template
      INSTALL_WATSON_KNOWLEDGE_CATALOG = var.install_watson_knowledge_catalog, // WKC
      INSTALL_WATSON_STUDIO            = var.install_watson_studio,            // WSL
      INSTALL_WATSON_MACHINE_LEARNING  = var.install_watson_machine_learning,  // WML
      INSTALL_WATSON_OPEN_SCALE        = var.install_watson_open_scale,        // AIOPENSCALE
      INSTALL_DATA_VIRTUALIZATION      = var.install_data_virtualization,      // DV
      INSTALL_STREAMS                  = var.install_streams,                  // STREAMS
      INSTALL_ANALYTICS_DASHBOARD      = var.install_analytics_dashboard,      // CDE
      INSTALL_SPARK                    = var.install_spark,                    // SPARK
      INSTALL_DB2_WAREHOUSE            = var.install_db2_warehouse,            // DB2WH
      INSTALL_DB2_DATA_GATE            = var.install_db2_data_gate,            // DATAGATE
      INSTALL_RSTUDIO                  = var.install_rstudio,                  // RSTUDIO
      INSTALL_DB2_DATA_MANAGEMENT      = var.install_db2_data_management,      // DMC
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
