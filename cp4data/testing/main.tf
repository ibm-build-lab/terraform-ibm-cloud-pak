// Requirements:

provider "ibm" {
  generation = var.infra == "classic" ? 1 : 2
  region     = "us-south"
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.group.id
  config_dir        = var.config_dir
}

locals {
  entitled_registry_key = file("${path.cwd}/../../entitlement.key")
}

// Module:

// TODO: With Terraform 0.13 replace the parameter 'enable' or the conditional expression using 'with_cp4data' with 'count'
module "cp4data" {
  source = "./.."
  enable = true
  force  = true

  // ROKS cluster parameters:
  openshift_version   = var.openshift_version
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path

  // Entitled Registry parameters:
  // 1. Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary
  // 2. Save the key to a file, update the file path in the entitled_registry_key parameter
  entitled_registry_key        = local.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // CPD Modules
  install_watson_knowledge_catalog = local.install_watson_knowledge_catalog
  install_watson_studio            = local.install_watson_studio
  install_watson_machine_learning  = local.install_watson_machine_learning
  install_watson_open_scale        = local.install_watson_open_scale
  install_data_virtualization      = local.install_data_virtualization
  install_streams                  = local.install_streams
  install_analytics_dashboard      = local.install_analytics_dashboard
  install_spark                    = local.install_spark
  install_db2_warehouse            = local.install_db2_warehouse
  install_db2_data_gate            = local.install_db2_data_gate
  install_rstudio                  = local.install_rstudio
  install_db2_data_management      = local.install_db2_data_management
}

// Output variables:

output "namespace" {
  value = module.cp4data.namespace
}
output "endpoint" {
  value = module.cp4data.endpoint
}
output "user" {
  value = module.cp4data.user
}
output "password" {
  value = module.cp4data.password
}

// Kubeconfig downloaded by this module
output "config_file_path" {
  value = data.ibm_container_cluster_config.cluster_config.config_file_path
}
output "cluster_config" {
  value = data.ibm_container_cluster_config.cluster_config
}
