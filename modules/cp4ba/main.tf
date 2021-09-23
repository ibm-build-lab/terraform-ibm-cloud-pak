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

resource "null_resource" "installing_cp4ba" {

  triggers = {
    PVC_FILE_sha1                         = sha1(local.pvc_file_content)
    CATALOG_SOURCE_FILE_sha1              = sha1(local.catalog_source_file_content)
    IBM_CP4BA_CRD_FILE_sha1               = sha1(local.ibm_cp4ba_crd_file_content)
    IBM_CP4BA_CR_FINAL_TMPL_FILE_sha1     = sha1(local.ibm_cp4ba_cr_final_tmpl_file_content)
    CP4BA_SUBSCRIPTION_FILE_sha1          = sha1(local.cp4ba_subscription_file_content)
  }

  provisioner "local-exec" {
    command = "/bin/bash ./scripts/install_cp4ba.sh"

    environment = {
      # ---- Cluster ----
      CLUSTER_NAME_OR_ID     = var.cluster_name_or_id
      # ---- IBM Cloud API Key ----
      IBMCLOUD_API_KEY = var.ibmcloud_api_key

      # ---- Platform ----
      PLATFORM_SELECTED             = local.platform_options
      PLATFORM_VERSION              = local.platform_version
      CP4BA_PROJECT_NAME            = var.cp4ba_project_name
      DEPLOYMENT_TYPE               = local.deployment_type
      RUNTIME_MODE                  = local.runtime_mode
      USER_NAME_EMAIL               = var.entitled_registry_user_email
      USE_ENTITLEMENT               = local.use_entitlement
      ENTITLED_REGISTRY_KEY         = var.entitlement_key
      # ---- Registry Images ----
      ENTITLED_REGISTRY_KEY_SECRET_NAME = local.entitled_registry_key_secret_name
      DOCKER_SERVER                 = local.docker_server
      DOCKER_USERNAME               = local.docker_username
      DOCKER_USER_EMAIL             = local.docker_email
      public_registry_server        = var.public_registry_server
      LOCAL_PUBLIC_REGISTRY_SERVER  = var.public_image_registry

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
      CP4BA_OCP_HOSTNAME               = var.cp4ba_ocp_hostname
      CP4BA_TLS_SECRET_NAME            = var.cp4ba_tls_secret_name
      CP4BA_ADMIN_PASSWORD             = var.cp4ba_admin_password
      CP4BA_UMS_ADMIN_PASSWORD         = var.cp4ba_ums_admin_password

      # ---- Storage Classes -----
      STORAGE_CLASSNAME                = var.storage_class_name
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
  }

}
