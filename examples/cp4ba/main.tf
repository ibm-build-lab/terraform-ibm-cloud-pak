provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
}

data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}

# go in the example
resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "mkdir -p ${local.cluster_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on        = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.resource_group.id
  config_dir        = local.cluster_config_path
}

module "install_cp4ba" {
  source = "../../modules/cp4ba"
//  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/cp4ba"
  enable = true

  # ---- Cluster settings ----
  cluster_config_path     = data.ibm_container_cluster_config.cluster_config.config_file_path
  ingress_subdomain       = var.ingress_subdomain
  # ---- Cloud Pak settings ----
  cp4ba_project_name      = var.cp4ba_project_name
  entitled_registry_user_email  = var.entitled_registry_user_email
  entitled_registry_key         = var.entitled_registry_key
    # ----- LDAP Settings -----
  ldap_admin    = var.ldap_admin
  ldap_password = var.ldap_password
  ldap_host_ip  = var.ldap_host_ip
  # ----- DB2 Settings -----
  db2_host_address = var.db2_host_address
  db2_ports = var.db2_ports
  db2_admin     = var.db2_admin
  db2_user      = var.db2_user
  db2_admin_user_password  = var.db2_admin_user_password

}


