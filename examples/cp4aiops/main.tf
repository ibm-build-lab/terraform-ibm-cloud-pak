provider "ibm" {
  region           = var.region
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
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.group.id
  config_dir        = var.cluster_config_path
}

module "cp4aiops" {
  source    = "../../modules/cp4aiops"
  enable    = true
  portworx_is_ready       = 1
  ibmcloud_api_key        = var.ibmcloud_api_key
  cluster_config_path     = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc                  = var.on_vpc
  entitled_registry_key   = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email
  cp4aiops_namespace      = var.cp4aiops_namespace
}