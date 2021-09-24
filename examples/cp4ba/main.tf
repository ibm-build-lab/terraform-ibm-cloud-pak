provider "ibm" {
  region           = var.region
  version          = "~> 1.12"
  ibmcloud_api_key = var.ibmcloud_api_key
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

# go in the example
resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "mkdir -p ${local.kube_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_name_or_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = true
  config_dir        = local.kube_config_path
  admin             = false
  network           = false
}

module "cp4ba" {
  source = "../../modules/cp4ba"

  enable = true

  CLUSTER_NAME_OR_ID     = var.cluster_name_or_id
  # ---- IBM Cloud API Key ----
  IBMCLOUD_API_KEY = var.ibmcloud_api_key

  # ---- Platform ----
  CP4BA_PROJECT_NAME            = "cp4ba"
  ENTITLED_REGISTRY_USER        = var.entitled_registry_user_email
  ENTITLED_REGISTRY_KEY         = var.entitlement_key

  # ------- FILES ASSIGNMENTS --------
//  OPERATOR_PVC_FILE                = local.pvc_file
//  CATALOG_SOURCE_FILE              = local.catalog_source_file
//  IBM_CP4BA_CRD_FILE               = local.ibm_cp4ba_crd_file
//  IBM_CP4BA_CR_FINAL_TMPL_FILE     = local.ibm_cp4ba_cr_final_tmpl_file
//  CP4BA_SUBSCRIPTION_FILE          = local.cp4ba_subscription_file

  # ----- DB2 Settings -----
  DB2_HOST_IP             = var.db2_host_ip
  DB2_HOST_PORT           = var.db2_host_port
  DB2_ADMIN_USERNAME      = var.db2_admin_username
  DB2_ADMIN_PASSWORD      = var.db2_admin_user_password

  # ----- LDAP Settings -----
  LDAP_ADMIN_NAME         = local.ldap_admin_name
  LDAP_ADMIN_PASSWORD     = var.ldap_admin_password
  LDAP_HOST_IP            = var.ldap_host_ip
}


