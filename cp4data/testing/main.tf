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
  source          = "./.."
  enable          = true
  install_version = var.install_version

  // ROKS cluster parameters:
  openshift_version   = var.openshift_version
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path

  // Entitled Registry parameters:
  // 1. Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary
  // 2. Save the key to a file, update the file path in the entitled_registry_key parameter
  entitled_registry_key        = local.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // Parameters for v3.0
  docker_id                                      = local.docker_id
  docker_access_token                            = local.docker_access_token
  install_guardium_external_stap                 = local.install_guardium_external_stap
  install_watson_assistant                       = local.install_watson_assistant
  install_watson_assistant_for_voice_interaction = local.install_watson_assistant_for_voice_interaction
  install_watson_discovery                       = local.install_watson_discovery
  install_watson_knowledge_studio                = local.install_watson_knowledge_studio
  install_watson_language_translator             = local.install_watson_language_translator
  install_watson_speech_text                     = local.install_watson_speech_text
  install_edge_analytics                         = local.install_edge_analytics

  // Parameters for v3.5
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
// output "endpoint" {
//   value = module.cp4data.endpoint
// }
// output "user" {
//   value = module.cp4data.user
// }
// output "password" {
//   value = module.cp4data.password
// }

// Kubeconfig downloaded by this module
output "config_file_path" {
  value = data.ibm_container_cluster_config.cluster_config.config_file_path
}
output "cluster_config" {
  value = data.ibm_container_cluster_config.cluster_config
}
