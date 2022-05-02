provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "mkdir -p ${var.cluster_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on        = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.group.id
  config_dir        = var.cluster_config_path
}

module "cp4mcm" {
  source           = "../../modules/cp4mcm"
  enable           = true
  on_vpc           = var.on_vpc
  region           = var.region
  zone             = var.zone
  ibmcloud_api_key = var.ibmcloud_api_key

  // ROKS cluster parameters:
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  cluster_name_id     = var.cluster_id

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // MCM specific variables
  namespace                    = local.namespace
  install_infr_mgt_module      = var.install_infr_mgt_module
  install_monitoring_module    = var.install_monitoring_module
  install_security_svcs_module = var.install_security_svcs_module
  install_operations_module    = var.install_operations_module
  install_tech_prev_module     = var.install_tech_prev_module
}
