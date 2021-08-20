provider "ibm" {
  version          = "~> 1.12"
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${local.kube_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.group.id
  config_dir        = local.kube_config_path
}

// Module:

module "cp4i" {
  source = "../../modules/cp4i"
  enable = true

  // ROKS cluster parameters:
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  //on_vpc              = var.on_vpc
  //portworx_is_ready   = 1           // Assuming portworx is installed if using VPC infrastructure
  storageclass         = var.storageclass

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  namespace           = "cp4i"
}
