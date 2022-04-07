locals {
  db2_operator_catalog_file = "${path.module}/files/ibm_operator_catalog.yaml"
  db2_operator_catalog_file_content = file(local.db2_operator_catalog_file)
  db2_storage_class_file = "${path.module}/files/storage_class.yaml"
  db2_storage_class_file_content = file(local.db2_storage_class_file)

  db2_operator_group_file_content = templatefile("${path.module}/templates/db2_operator_group.yaml.tmpl", {
    paramDB2Namespace = var.db2_project_name
  })

  c_db2ucluster_db2u_file_content = templatefile("${path.module}/templates/c-db2ucluster-db2u.yaml.tmpl", {
    paramDB2Namespace = var.db2_project_name
  })

  c_db2ucluster_etcd_file_content = templatefile("${path.module}/templates/c-db2ucluster-etcd.yaml.tmpl", {
    paramDB2Namespace = var.db2_project_name
  })

  db2_subscription_file_content = templatefile("${path.module}/templates/db2_subscription.yaml.tmpl", {
    paramDB2Namespace       = var.db2_project_name
    paramDB2OperatorVersion = var.operatorVersion
    paramDB2OperatorChannel = var.operatorChannel
})

  db2u_cluster_file       = templatefile("${path.module}/templates/db2u_cluster.yaml.tmpl", {
    db2OnOcpProjectName   = var.db2_project_name
    db2_name              = var.db2_name
    db2AdminUserPassword  = var.db2_admin_user_password
    db2InstanceVersion    = var.db2_instance_version
    db2License            = var.db2_standard_license_key == "" ? "accept: true" : join("value: ", var.db2_standard_license_key)
    db2Cpu                = var.db2_cpu
    db2Memory             = var.db2_memory
    db2StorageSize        = var.db2_storage_size
    db2OnOcpStorageClassName = var.db2_storage_class
  })
}

resource "null_resource" "install_db2" {
  count = var.enable_db2 ? 1 : 0

  triggers = {
    db2_file_sha1                  = sha1(local.db2u_cluster_file)
    db2_operator_group_file_sha1   = sha1(local.db2_operator_group_file_content)
    db2_subscription_file_sha1     = sha1(local.db2_subscription_file_content)
    db2_operator_catalog_file_sha1 = sha1(local.db2_operator_catalog_file)
    db2_storage_class_file_sha1    = sha1(local.db2_storage_class_file)
    docker_credentials_sha1        = sha1(join("", [var.entitled_registry_key, var.entitled_registry_user_email, var.db2_project_name]))
    c_db2ucluster_db2u_file_content_sha1 = sha1(local.c_db2ucluster_db2u_file_content)
    c_db2ucluster_etcd_file_content_sha1 = sha1(local.c_db2ucluster_etcd_file_content)
  }

  # --------------- PROVISION DB2  ------------------
  provisioner "local-exec" {
    command = "${path.module}/scripts/install_Db2.sh"

    environment = {
      # ----- Cluster -----
      KUBECONFIG = var.cluster_config_path
      # ----- Platform -----
      DB2_PROJECT_NAME         = var.db2_project_name
      DB2_NAME                 = var.db2_name
      DB2_ADMIN_USERNAME       = var.db2_admin_username
      DB2_ADMIN_USER_PASSWORD  = var.db2_admin_user_password
      DB2_STANDARD_LICENSE_KEY = var.db2_standard_license_key
      DB2_OPERATOR_VERSION     = var.operatorVersion
      DB2_OPERATOR_CHANNEL     = var.operatorChannel
      DB2_INSTANCE_VERSION     = var.db2_instance_version
      DB2_CPU                  = var.db2_cpu
      DB2_MEMORY               = var.db2_memory
      DB2_STORAGE_SIZE         = var.db2_storage_size
      DB2_STORAGE_CLASS        = var.db2_storage_class
      # ------ FILES ASSIGNMENTS -----------
      DB2_OPERATOR_CATALOG_FILE  = local.db2_operator_catalog_file
      DB2_STORAGE_CLASS_FILE     = local.db2_storage_class_file
      DB2U_CLUSTER_CONTENT       = local.db2u_cluster_file
      DB2_OPERATOR_GROUP_CONTENT = local.db2_operator_group_file_content
      DB2_SUBSCRIPTION_CONTENT   = local.db2_subscription_file_content
      C_DB2UCLUSTER_DB2U_FILE_CONTENT = local.c_db2ucluster_db2u_file_content
      C_DB2UCLUSTER_ETCD_FILE_CONTENT = local.c_db2ucluster_etcd_file_content
      # ------ Docker Information ----------
      ENTITLED_REGISTRY_KEY           = var.entitled_registry_key
      ENTITLEMENT_REGISTRY_USER_EMAIL = var.entitled_registry_user_email
      DOCKER_SERVER                   = local.docker_server
      DOCKER_USERNAME                 = local.docker_username
    }
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "./uninstall_db2.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      kubeconfig        = self.triggers.kubeconfig
      db2_project_name  = self.triggers.namespace
    }
  }
}


data "external" "get_endpoints" {
  count           = var.enable_db2 ? 1 : 0
  depends_on      = [null_resource.install_db2]
  program         = ["/bin/bash", "${path.module}/scripts/get_db2_endpoints.sh"]
  query = {
    kubeconfig    = var.cluster_config_path
    db2_namespace = var.db2_project_name
  }
}



