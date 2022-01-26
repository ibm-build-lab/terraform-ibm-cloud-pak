locals {
  db2_operator_group_file           = "${path.module}/files/db2_operator_group.yaml"
  db2_operator_group_file_content   = file(local.db2_operator_group_file)
  db2_subscription_file             = "${path.module}/files/db2_subscription.yaml"
  db2_subscription_file_content     = file(local.db2_subscription_file)
  db2_operator_catalog_file         = "${path.module}/files/ibm_operator_catalog.yaml"
  db2_operator_catalog_file_content = file(local.db2_operator_group_file)
  db2_storage_class_file            = "${path.module}/files/storage_class.yaml"
  db2_storage_class_file_content    = file(local.db2_storage_class_file)
  db2_file = templatefile("${path.module}/files/db2.yaml", {
    db2_license = local.db2_standard_license_key
  })
}


resource "null_resource" "install_db2" {
  count = var.enable ? 1 : 0

  triggers = {
    db2_file_sha1                  = sha1(local.db2_file)
    db2_operator_group_file_sha1   = sha1(local.db2_operator_group_file)
    db2_subscription_file_sha1     = sha1(local.db2_subscription_file)
    db2_operator_catalog_file_sha1 = sha1(local.db2_operator_catalog_file)
    db2_storage_class_file_sha1    = sha1(local.db2_storage_class_file)
  }

  # --------------- PROVISION DB2  ------------------
  provisioner "local-exec" {
    command = "${path.module}/scripts/install_Db2.sh"

    environment = {
      # ----- Cluster -----
      KUBECONFIG = var.cluster_config_path

      # ----- Platform -----
      DB2_PROJECT_NAME        = local.db2_project_name
      DB2_ADMIN_USER_NAME     = local.db2_admin_user_name
      DB2_ADMIN_USER_PASSWORD = local.db2_admin_user_password

      # ------ FILES ASSIGNMENTS -----------
      DB2_OPERATOR_GROUP_FILE   = local.db2_operator_group_file
      DB2_SUBSCRIPTION_FILE     = local.db2_subscription_file
      DB2_OPERATOR_CATALOG_FILE = local.db2_operator_catalog_file
      DB2_STORAGE_CLASS_FILE    = local.db2_storage_class_file
      DB2_FILE                  = local.db2_file

      # ------ Docker Information ----------
      ENTITLED_REGISTRY_KEY           = var.entitlement_key
      ENTITLEMENT_REGISTRY_USER_EMAIL = var.entitled_registry_user_email
      DOCKER_SERVER                   = local.docker_server
      DOCKER_USERNAME                 = local.docker_username
    }
  }
}