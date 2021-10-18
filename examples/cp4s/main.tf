// Requirements:

provider "ibm" {
  region = var.region
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
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
module "cp4s" {
  source = "./.."
  enable = var.enable

  // ROKS cluster parameters:
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path



  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // LDAP configuration
  ldap_user_id = var.ldap_user_id
  ldap_status  = var.ldap_status
}