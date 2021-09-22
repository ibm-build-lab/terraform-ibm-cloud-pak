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
  app_registry_file                     = "${path.module}/files/app_registry.yaml"
  app_registry_file_content             = file(local.app_registry_file)
  operator_group_file                   = "${path.module}/files/operator_group.yaml"
  operator_group_file_content           = file(local.operator_group_file)
  operator_subscription_file            = "${path.module}/files/operator_subscription.yaml"
  operator_subscription_file_content    = file(local.operator_subscription_file)
  operator_operand_request_file         = "${path.module}/files/operator_operandrequest_cr.yaml"
  operator_operand_request_file_content = file(local.operator_operand_request_file)
  operator_file                         = "${path.module}/files/operator.yaml"
  operator_file_content                 = file(local.operator_file)
  catalog_source_file                   = "${path.module}/files/catalog_source.yaml"
  catalog_source_file_content           = file(local.catalog_source_file)
  operator_operand_registry_cr_file     = "${path.module}/files/operator_operandregistry_cr.yaml"
  operator_operand_registry_cr_file_content = file(local.operator_operand_registry_cr_file)
  operator_operand_config_cr_file           = "${path.module}/files/operator_operandconfig_cr.yaml"
  operator_operand_config_cr_file_content   = file(local.operator_operand_config_cr_file)

  role_file                             = "${path.module}/files/role.yaml"
  role_file_content                     = file(local.role_file)
  role_binding_file                     = "${path.module}/files/role_binding.yaml"
  role_binding_file_content             = file(local.role_binding_file)
  service_account_file                  = "${path.module}/files/service_account.yaml"
  service_account_file_content          = file(local.service_account_file)
  ibm_cp4ba_crd_file                    = "${path.module}/files/ibm_cp4ba_crd.yaml"
  ibm_cp4ba_crd_file_content            = file(local.ibm_cp4ba_crd_file)
  ibm_cp4ba_cr_final_tmpl_file          = "${path.module}/files/ibm_cp4ba_cr_final_tmpl.yaml"
  ibm_cp4ba_cr_final_tmpl_file_content  = file(local.ibm_cp4ba_cr_final_tmpl_file)
  cp4ba_subscription_file               = "${path.module}/files/cp4ba_subscription.yaml"
  cp4ba_subscription_file_content       = file(local.cp4ba_subscription_file)
  automation_ui_config_file             = "${path.module}/files/automationUIConfig.yaml"
  automation_ui_config_file_content     = file(local.automation_ui_config_file)
  cartridge_file                        = "${path.module}/files/cartridge.yaml"
  cartridge_file_content                = file(local.cartridge_file)
}


module "cp4ba" {
  source = "./.."

  enable = true

  CLUSTER_NAME_OR_ID     = var.cluster_name_or_id
  //   IBM Cloud API Key
      IBMCLOUD_API_KEY = var.ibmcloud_api_key

      # Cluster
  //    on_vpc                        = var.on_vpc
  //    portworx_is_ready             = var.portworx_is_ready
  //    namespace                     = local.cp4ba_namespace
  //
  //    # Platform
      PLATFORM_SELECTED             = local.platform_options
      PLATFORM_VERSION              = local.platform_version
      CP4BA_PROJECT_NAME            = var.cp4ba_project_name
      DEPLOYMENT_TYPE               = local.deployment_type
      RUNTIME_MODE                  = local.runtime_mode
      USER_NAME_EMAIL               = var.entitled_registry_user_email
      USE_ENTITLEMENT               = local.use_entitlement
      ENTITLED_REGISTRY_KEY         = var.entitlement_key # file("${path.cwd}/../../entitlement.key")
      # Registry Images
      ENTITLED_REGISTRY_KEY_SECRET_NAME = local.entitled_registry_key_secret_name
      DOCKER_SERVER                 = local.docker_server
      DOCKER_USERNAME               = local.docker_username
      DOCKER_USER_EMAIL             = local.docker_email
      public_registry_server        = var.public_registry_server
      LOCAL_PUBLIC_REGISTRY_SERVER  = var.public_image_registry

      # ------- FILES ASSIGNMENTS --------
      OPERATOR_PVC_FILE                = local.pvc_file
      CS_APP_REGISTRY_FILE             = local.app_registry_file
      CS_OPERATOR_GROUP_FILE           = local.operator_group_file
      CS_OPERATOR_SUBSCRIPTION_FILE    = local.operator_subscription_file
      CS_OPERATOR_OPERAND_REQUEST_FILE = local.operator_operand_request_file
      CATALOG_SOURCE_FILE              = local.catalog_source_file
      OPERATOR_OPERANDREGISTRY_CR_FILE = local.operator_operand_registry_cr_file
      OPERATOR_OPERANDCONFIG_CR_FILE   = local.operator_operand_config_cr_file
      OPERATOR_FILE                    = local.operator_file
      ROLE_FILE                        = local.role_file
      ROLE_BINDING_FILE                = local.role_binding_file
      SERVICE_ACCOUNT_FILE             = local.service_account_file
      CARTRIDGE_FILE                   = local.cartridge_file
      AUTOMATION_UI_CONFIG_FILE        = local.automation_ui_config_file

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

  //    # Storage Classes
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
}
