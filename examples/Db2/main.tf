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
  cluster_name_id   = var.cluster_name_or_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = true
  config_dir        = var.cluster_config_path
  admin             = false
  network           = false
}

module "Db2" {
  source = "../../modules/Db2"
  enable = true

  # ----- Cluster -----
  KUBECONFIG = data.ibm_container_cluster_config.cluster_config.config_file_path

  # ----- Platform -----
  DB2_PROJECT_NAME        = local.db2_project_name
  DB2_ADMIN_USER_NAME     = local.db2_admin_user_name
  DB2_ADMIN_USER_PASSWORD = local.db2_admin_user_password

  # ------ Docker Information ----------
  ENTITLED_REGISTRY_KEY           = var.entitlement_key
  ENTITLEMENT_REGISTRY_USER_EMAIL = var.entitled_registry_user_email
  DOCKER_SERVER                   = local.docker_server
  DOCKER_USERNAME                 = local.docker_username
}