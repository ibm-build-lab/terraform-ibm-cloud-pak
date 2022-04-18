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
    command = "mkdir -p ${var.cluster_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on        = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.resource_group.id
  config_dir        = var.cluster_config_path
}

module "install_cp4ba" {
<<<<<<< HEAD
  source     = "../../modules/cp4ba"
  enable_cp4ba           = true
  enable_db2             = true
  ibmcloud_api_key       = var.ibmcloud_api_key
  region                 = var.region
  resource_group         = var.resource_group
  cluster_id             = var.cluster_id
  cluster_config_path    = data.ibm_container_cluster_config.cluster_config.config_file_path
  ingress_subdomain      = var.ingress_subdomain
  # ---- Platform ----
  cp4ba_project_name           = var.cp4ba_project_name
=======
  source = "../../modules/cp4ba"
//  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/cp4ba"
  enable_cp4ba           = true
  ibmcloud_api_key       = var.ibmcloud_api_key
  region                 = var.region
  cluster_config_path    = data.ibm_container_cluster_config.cluster_config.config_file_path
  ingress_subdomain      = var.ingress_subdomain
  # ---- Platform ----
  cp4ba_project_name     = var.cp4ba_project_name
>>>>>>> main
  entitled_registry_user_email = var.entitled_registry_user_email
  entitled_registry_key        = var.entitled_registry_key
  # ----- LDAP Settings -----
  ldap_admin_name         = var.ldap_admin_name
  ldap_admin_password     = var.ldap_admin_password
  ldap_host_ip            = var.ldap_host_ip
  # ----- DB2 Settings -----
<<<<<<< HEAD
  db2_project_name        = var.db2_project_name
  db2_admin_username      = var.db2_admin_username
  db2_admin_user_password = var.db2_admin_user_password
  db2_host_address        = var.db2_host_address
  db2_ports               = var.db2_ports
=======
  db2_host_port           = var.db2_host_port # != null ? var.db2_ports : module.install_db2.db2_ports # var.db2_port_number
  db2_host_address        = var.db2_host_address
  db2_admin_username      = var.db2_admin_username
  db2_admin_user_password = var.db2_admin_user_password

>>>>>>> main
}


