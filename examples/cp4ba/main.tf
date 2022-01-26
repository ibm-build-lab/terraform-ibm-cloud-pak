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
  cluster_name_id   = var.cluster_name_or_id
  resource_group_id = data.ibm_resource_group.resource_group.id
  config_dir        = local.cluster_config_path
}

module "cp4ba" {
  source = "../../modules/cp4ba"
//  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/terraform-0.13/modules/cp4ba"
  enable = true

  # ---- Cluster settings ----
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  ingress_subdomain = var.ingress_subdomain

  # ---- Cloud Pak settings ----
  cp4ba_project_name      = "cp4ba"
  entitled_registry_user  = var.entitled_registry_user
  entitlement_key         = var.entitlement_key

  # ----- DB2 Settings -----
  db2_host_name = var.db2_host_name
  db2_host_port = var.db2_host_port
  db2_admin     = var.db2_admin
  db2_user      = var.db2_user
  db2_password  = var.db2_password

  # ----- LDAP Settings -----
  ldap_admin    = var.ldap_admin
  ldap_password = var.ldap_password
  ldap_host_ip  = var.ldap_host_ip
}


