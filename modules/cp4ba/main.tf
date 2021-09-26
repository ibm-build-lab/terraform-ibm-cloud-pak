locals {
  pvc_file                              = "${path.module}/files/cp4ba-pvc.yaml"
  pvc_file_content                      = file(local.pvc_file)
  catalog_source_file                   = "${path.module}/files/catalog_source.yaml"
  catalog_source_file_content           = file(local.catalog_source_file)
  # ibm_cp4ba_crd_file                    = "${path.module}/files/ibm_cp4ba_crd.yaml"
  # ibm_cp4ba_crd_file_content            = file(local.ibm_cp4ba_crd_file)
  # ibm_cp4ba_cr_final_tmpl_file          = "${path.module}/files/ibm_cp4ba_cr_final_tmpl.yaml"
  # ibm_cp4ba_cr_final_tmpl_file_content  = file(local.ibm_cp4ba_cr_final_tmpl_file)
  cp4ba_subscription_file               = "${path.module}/files/cp4ba_subscription.yaml"
  cp4ba_subscription_file_content       = file(local.cp4ba_subscription_file)
  cp4ba_deployment_content = templatefile("${path.module}/templates/cp4ba_deployment.yaml.tmpl", {
    ldap_host_ip     = var.ldap_host_ip,
    db2_admin        = var.db2_admin,
    db2_host_ip      = var.db2_host_ip,
    db2_host_port    = var.db2_host_port
  })
  secrets_content = templatefile("${path.module}/templates/secrets.yaml.tmpl", {
    ldap_admin       = var.ldap_admin,
    ldap_password    = var.ldap_password,
    db2_admin        = var.db2_admin,
    db2_user         = var.db2_user,
    db2_password     = var.db2_password
  })
}

resource "null_resource" "installing_cp4ba" {
  count = var.enable ? 1 : 0

  triggers = {
    PVC_FILE_sha1                         = sha1(local.pvc_file_content)
    CATALOG_SOURCE_FILE_sha1              = sha1(local.catalog_source_file_content)
    CP4BA_SUBSCRIPTION_FILE_sha1          = sha1(local.cp4ba_subscription_file_content)
    CP4BA_DEPLOYMENT_sha1                 = sha1(local.cp4ba_deployment_content)
    SECRET_sha1                           = sha1(local.secrets_content)
    # IBM_CP4BA_CRD_FILE_sha1               = sha1(local.ibm_cp4ba_crd_file_content)
    # IBM_CP4BA_CR_FINAL_TMPL_FILE_sha1     = sha1(local.ibm_cp4ba_cr_final_tmpl_file_content)
  }

  provisioner "local-exec" {
    command = "/bin/bash ./scripts/install_cp4ba.sh"

    environment = {
      # ---- Cluster ----
      CLUSTER_NAME_OR_ID     = var.cluster_name_or_id
      # ---- IBM Cloud API Key ----
      #IBMCLOUD_API_KEY = var.ibmcloud_api_key

      # ---- Platform ----
      CP4BA_PROJECT_NAME            = var.cp4ba_project_name

      # ---- Registry Images ----
      ENTITLED_REGISTRY_EMAIL       = var.entitled_registry_user_email
      ENTITLED_REGISTRY_KEY         = var.entitlement_key
      DOCKER_SERVER                 = local.docker_server
      DOCKER_USERNAME               = local.docker_username

      # ------- FILES ASSIGNMENTS --------
      OPERATOR_PVC_FILE                = local.pvc_file
      CATALOG_SOURCE_FILE              = local.catalog_source_file
      CP4BA_SUBSCRIPTION_FILE          = local.cp4ba_subscription_file
      CP4BA_DEPLOYMENT_CONTENT         = local.cp4ba_deployment_content
      SECRETS_CONTENT                  = local.secrets_content
    }
  }
}
