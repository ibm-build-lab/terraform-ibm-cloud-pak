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

// Module:

module "iaf" {
  source = "../../modules/iaf"
  enable = true

  // ROKS cluster parameters:
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  cluster_name_id     = var.cluster_id
  on_vpc              = var.on_vpc
  region              = var.region
  resource_group      = var.resource_group

  // IBM Cloud API Key
  ibmcloud_api_key = var.ibmcloud_api_key

  // Entitled Registry parameters:
  // 1. Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary
  // 2. Save the key to a file, or list here
  entitled_registry_key        = length(var.entitled_registry_key) > 0 ? var.entitled_registry_key : file(local.entitled_registry_key_file)
  entitled_registry_user_email = var.entitled_registry_user_email
}
