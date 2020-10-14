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

module "cp4app" {
  source = "./.."
  enable = true

  // Entitled Registry parameters:
  // 1. Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary
  // 2. Save the key to a file, update the file path in the entitled_registry_key parameter
  entitled_registry_key        = file("${path.cwd}/../../entitlement.key")
  entitled_registry_user_email = var.entitled_registry_user_email

  cluster_config_path     = data.ibm_container_cluster_config.cluster_config.config_file_path
  cp4app_installer_comand = "install"
}

// Output variables:

output "namespace" {
  value = module.cp4app.installer_namespace
}
output "endpoint" {
  value = module.cp4app.endpoint
}
output "advisor_ui_endpoint" {
  value = module.cp4app.advisor_ui_endpoint
}
output "navigator_ui_endpoint" {
  value = module.cp4app.navigator_ui_endpoint
}


// Kubeconfig downloaded by this module
output "config_file_path" {
  value = data.ibm_container_cluster_config.cluster_config.config_file_path
}
output "cluster_config" {
  value = data.ibm_container_cluster_config.cluster_config
}
