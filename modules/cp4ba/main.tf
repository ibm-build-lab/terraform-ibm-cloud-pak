locals {
  operator_group_file                   = "${path.module}/files/operator-group.yaml"
  operator_group_file_content           = file(local.operator_group_file)
  catalog_source_file                   = "${path.module}/files/catalog_source.yaml"
  catalog_source_file_content           = file(local.catalog_source_file)
  common_service_file                   = "${path.module}/files/common-service.yaml"
  common_service_file_content           = file(local.common_service_file)
  roles_file                            = "${path.module}/files/roles.yaml"
  roles_file_content                    = file(local.roles_file)
  role_binding_file                     = "${path.module}/files/role_binding.yaml"
  role_binding_content                  = file(local.role_binding_file)
  cp4ba_subscription_file_content       = templatefile("${path.module}/templates/cp4ba_subscription.yaml.tmpl", {
    cp4ba_project_name = var.cp4ba_project_name
  })
  operator_shared_pv_file_content   = templatefile("${path.module}/templates/operator_shared_pv.yaml.tmpl", {
    cp4ba_project_name = var.cp4ba_project_name
  })
  shared_log_pv_file_content        = templatefile("${path.module}/templates/cp4a_shared_log_pv.yaml.tmpl", {
    cp4ba_project_name = var.cp4ba_project_name
  })
  operator_shared_pvc_file_content  = templatefile("${path.module}/templates/operator_shared_pvc.yaml.tmpl", {
    cp4ba_project_name = var.cp4ba_project_name
  })
  shared_log_pvc_file_content       = templatefile("${path.module}/templates/cp4a_shared_log_pvc.yaml.tmpl", {
    cp4ba_project_name = var.cp4ba_project_name
  })
  cp4ba_deployment_credentials_file_content = "${path.module}/templates/cp4ba_deployment_credentials.yaml.tmpl"
  cp4ba_deployment_file_content             = templatefile("${path.module}/templates/cp4ba_deployment.yaml.tmpl", {
    ldap_host_ip     = var.ldap_host_ip,
    db2_host_address = var.db2_host_address,
    db2_host_port    = var.db2_host_port,
    ingress_subdomain = var.ingress_subdomain
  })
  secrets_content    = templatefile("${path.module}/templates/secrets.yaml.tmpl", {
    ldap_admin       = var.ldap_admin_name,
    ldap_password    = var.ldap_admin_password,
    db2_admin        = var.db2_admin_username,
    db2_user         = var.db2_user,
    db2_password     = var.db2_admin_user_password
  })
}

resource "null_resource" "installing_cp4ba" {

  triggers = {
    OPERATOR_SHARED_PV_FILE_sha1          = sha1(local.operator_shared_pv_file_content)
    SHARED_LOG_PV_FILE_sha1               = sha1(local.shared_log_pv_file_content)

    OPERATOR_SHARED_PVC_FILE_sha1         = sha1(local.operator_shared_pvc_file_content)
    SHARED_LOG_PVC_FILE_sha1              = sha1(local.shared_log_pvc_file_content)
    OPERATOR_GROUP_sha1                   = sha1(local.operator_group_file_content)
    CATALOG_SOURCE_FILE_sha1              = sha1(local.catalog_source_file_content)
    CP4BA_SUBSCRIPTION_FILE_sha1          = sha1(local.cp4ba_subscription_file_content)
    cp4ba_deployment_credentials_sha1     = sha1(local.cp4ba_deployment_credentials_file_content)
    CP4BA_DEPLOYMENT_sha1                 = sha1(local.cp4ba_deployment_file_content)
    SECRET_sha1                           = sha1(local.secrets_content)
    ROLES_sha1                            = sha1(local.roles_file_content)
    ROLE_BINDING_sha1                     = sha1(local.role_binding_content)
    COMMON_SERVICE_FILE_sha1              = sha1(local.common_service_file_content)
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/install_cp4ba.sh"

    environment = {
      # ---- Cluster ----
      KUBECONFIG                    = var.cluster_config_path
      # ---- Platform ----
      CP4BA_PROJECT_NAME            = var.cp4ba_project_name
      # ---- Registry Images ----
      ENTITLED_REGISTRY_EMAIL       = var.entitled_registry_user_email
      ENTITLED_REGISTRY_KEY         = var.entitled_registry_key
      DOCKER_SERVER                 = local.docker_server
      DOCKER_USERNAME               = local.docker_username
      # ------- FILES ASSIGNMENTS --------
      OPERATOR_SHARED_PV_FILE          = local.operator_shared_pv_file_content
      SHARED_LOG_PV_FILE               = local.shared_log_pv_file_content
      OPERATOR_SHARED_PVC_FILE         = local.operator_shared_pvc_file_content
      SHARED_LOG_PVC_FILE              = local.shared_log_pvc_file_content
      OPERATOR_GROUP_FILE              = local.operator_group_file
      CATALOG_SOURCE_FILE              = local.catalog_source_file
      COMMON_SERVICE_FILE              = local.common_service_file
      CP4BA_SUBSCRIPTION_FILE          = local.cp4ba_subscription_file_content
      CP4BA_DEPLOYMENT_CREDENTIALS_FILE = local.cp4ba_deployment_credentials_file_content
      CP4BA_DEPLOYMENT_CONTENT         = local.cp4ba_deployment_file_content
      SECRETS_CONTENT                  = local.secrets_content
      ROLES_FILE                       = local.roles_file
      ROLE_BINDING_FILE                = local.role_binding_file

      ldap_admin              = var.ldap_admin_name
      ldap_password           = var.ldap_admin_password
      ldap_host_ip            = var.ldap_host_ip
      # ----- DB2 Settings -----
      db2_host_port           = var.db2_host_port # != null ? var.db2_ports : module.install_db2.db2_ports # var.db2_port_number
      db2_host_address        = var.db2_host_address
      db2_admin               = var.db2_admin_username
      db2_password            = var.db2_admin_user_password
      db2_user                = var.db2_user
    }
  }
}

data "external" "get_endpoints" {
  count = 1

  depends_on = [
    null_resource.installing_cp4ba
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.cp4ba_project_name
  }
}
