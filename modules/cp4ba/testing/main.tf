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
    command = "mkdir -p ${var.kube_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_name_or_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = true
  config_dir        = ".kube/config"
  admin             = false
  network           = false
}

locals {
  pvc_file                              = "${path.module}/files/operator-shared-pvc.yaml"
  pvc_file_content                      = file(local.pvc_file)
  catalog_source_file                   = "${path.module}/files/catalog_source.yaml"
  catalog_source_file_content           = file(local.catalog_source_file)
  ibm_cp4ba_crd_file                    = "${path.module}/files/ibm_cp4ba_crd.yaml"
  ibm_cp4ba_crd_file_content            = file(local.ibm_cp4ba_crd_file)
  ibm_cp4ba_cr_final_tmpl_file          = "${path.module}/files/ibm_cp4ba_cr_final_tmpl.yaml"
  ibm_cp4ba_cr_final_tmpl_file_content  = file(local.ibm_cp4ba_cr_final_tmpl_file)
  cp4ba_subscription_file               = "${path.module}/files/cp4ba_subscription.yaml"
  cp4ba_subscription_file_content       = file(local.cp4ba_subscription_file)
}

module "cp4ba" {
  source = "./.."

  enable = true

  CLUSTER_NAME_OR_ID     = var.cluster_name_or_id
      # ---- IBM Cloud API Key ----
      IBMCLOUD_API_KEY = var.ibmcloud_api_key

      # ---- Platform ----
      CP4BA_PROJECT_NAME            = var.cp4ba_project_name
      USER_NAME_EMAIL               = var.entitled_registry_user_email
      USE_ENTITLEMENT               = local.use_entitlement
      ENTITLED_REGISTRY_KEY         = var.entitlement_key
      # ---- Registry Images ----
      ENTITLED_REGISTRY_KEY_SECRET_NAME = local.entitled_registry_key_secret_name
      DOCKER_SERVER                 = local.docker_server
      DOCKER_USERNAME               = local.docker_username
      DOCKER_USER_EMAIL             = local.docker_email

      # ------- FILES ASSIGNMENTS --------
      OPERATOR_PVC_FILE                = local.pvc_file
      CATALOG_SOURCE_FILE              = local.catalog_source_file
      IBM_CP4BA_CRD_FILE               = local.ibm_cp4ba_crd_file
      IBM_CP4BA_CR_FINAL_TMPL_FILE     = local.ibm_cp4ba_cr_final_tmpl_file
      CP4BA_SUBSCRIPTION_FILE          = local.cp4ba_subscription_file
      CP4BA_ADMIN_NAME                 = local.cp4ba_admin_name
      CP4BA_ADMIN_GROUP                = local.cp4ba_admin_group
      CP4BA_USERS_GROUP                = local.cp4ba_users_group
      CP4BA_UMS_ADMIN_NAME             = local.cp4ba_ums_admin_name
      CP4BA_UMS_ADMIN_GROUP            = local.cp4ba_ums_admin_group
      CP4BA_ADMIN_PASSWORD             = var.cp4ba_admin_password
      CP4BA_UMS_ADMIN_PASSWORD         = var.cp4ba_ums_admin_password

      # ---- Storage Classes ----
      SC_SLOW_FILE_STORAGE_CLASSNAME   = var.sc_slow_file_storage_classname
      SC_MEDIUM_FILE_STORAGE_CLASSNAME = var.sc_medium_file_storage_classname
      SC_FAST_FILE_STORAGE_CLASSNAME   = var.sc_fast_file_storage_classname

      # ----- DB2 Settings -----
      DB2_PORT_NUMBER         = var.db2_port_number
      DB2_HOST_NAME           = var.db2_host_name
      DB2_HOST_IP             = var.db2_host_ip
      DB2_ADMIN_USERNAME      = var.db2_admin_username
      DB2_ADMIN_USER_PASSWORD = var.db2_admin_user_password

      # ----- LDAP Settings -----
      LDAP_ADMIN_NAME         = local.ldap_admin_name
      LDAP_ADMIN_PASSWORD     = var.ldap_admin_password
}


