locals {
  cp4ba_storage_class_file                    = "${path.module}/files/cp4ba_storage_class.yaml"
  cp4ba_storage_class_file_content            = file(local.cp4ba_storage_class_file)
  pvc_file                              = "${path.module}/files/operator_shared_pvc.yaml"
  pvc_file_content                      = file(local.pvc_file)
  catalog_source_file                   = "${path.module}/files/catalog_source.yaml"
  catalog_source_file_content           = file(local.catalog_source_file)
  cp4ba_subscription_content = templatefile("${path.module}/templates/cp4ba_subscription.yaml.tmpl", {
    namespace        = var.cp4ba_project_name,
  })
  cp4ba_deployment_content = templatefile("${path.module}/templates/cp4ba_deployment.yaml.tmpl", {
    ldap_host_ip     = var.ldap_host_ip,
    db2_admin        = var.db2_admin,
    db2_host_name    = var.db2_host_name,
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
    STORAGE_CLASS_FILE_sha1               = sha1(local.cp4ba_storage_class_file_content)
    CATALOG_SOURCE_FILE_sha1              = sha1(local.catalog_source_file_content)
    CP4BA_SUBSCRIPTION_FILE_sha1          = sha1(local.cp4ba_subscription_content)
    CP4BA_DEPLOYMENT_sha1                 = sha1(local.cp4ba_deployment_content)
    SECRET_sha1                           = sha1(local.secrets_content)
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/install_cp4ba.sh"

    environment = {
      # ---- Cluster ----
      KUBECONFIG                    = var.cluster_config_path

      # ---- Platform ----
      CP4BA_PROJECT_NAME            = var.cp4ba_project_name

      # ---- Registry Images ----
      ENTITLED_REGISTRY_EMAIL       = var.entitled_registry_user
      ENTITLED_REGISTRY_KEY         = var.entitlement_key
      DOCKER_SERVER                 = local.docker_server
      DOCKER_USERNAME               = local.docker_username

      # ------- FILES ASSIGNMENTS --------
      CP4BA_STORAGE_CLASS_FILE      = local.cp4ba_storage_class_file
      OPERATOR_PVC_FILE             = local.pvc_file
      CATALOG_SOURCE_FILE           = local.catalog_source_file
      CP4BA_SUBSCRIPTION_CONTENT    = local.cp4ba_subscription_content
      CP4BA_DEPLOYMENT_CONTENT      = local.cp4ba_deployment_content
      SECRETS_CONTENT               = local.secrets_content
    }
  }
}

data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.installing_cp4ba
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.cp4ba_project_name
  }
}

