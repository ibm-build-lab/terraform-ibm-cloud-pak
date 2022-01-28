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
    command = "mkdir -p ${local.cluster_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on        = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = true
  config_dir        = local.cluster_config_path
  admin             = false
  network           = false
}

module "Db2" {
  source = "..\/..\/modules\/Db2"
  enable = true

  # ----- Cluster -----
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path

  # ----- Platform -----
  db2_project_name        = var.db2_project_name
  db2_admin_username      = var.db2_admin_username
  db2_admin_user_password = var.db2_admin_user_password
  db2_standard_license_key = var.db2_standard_license_key

  # ------ Docker Information ----------
  entitlement_key           = var.entitlement_key
  entitled_registry_user_email = var.entitled_registry_user_email
//  docker_server                   = local.docker_server
//  docker_username                 = local.docker_username
}