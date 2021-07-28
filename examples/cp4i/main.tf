provider "ibm" {
  region           = var.region
  version          = "~> 1.12"
  ibmcloud_api_key = var.ibmcloud_api_key
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${local.config_dir}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.group.id
  config_dir        = local.config_dir
}

// Module:

module "cp4i" {
  source = "../../modules/cp4i"
  // TODO: With Terraform 0.13 replace the parameter 'enable' or the conditional expression using 'with_cp4i' with 'count'
  enable = true

  // ROKS cluster parameters:
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc

  // Entitled Registry parameters:
  // 1. Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary
  // 2. Save the key to a file, or list here
  entitled_registry_key        = length(var.entitled_registry_key) > 0 ? var.entitled_registry_key : file(local.entitled_registry_key_file)
  entitled_registry_user_email = var.entitled_registry_user_email

  portworx_is_ready   = 1           // Assuming portworx is installed if using VPC infrastructure
  namespace           = "cp4i"
}
