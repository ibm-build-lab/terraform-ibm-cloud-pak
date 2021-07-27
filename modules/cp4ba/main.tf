data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "null_resource" "setting_platform" {

//    depends_on = [module.cluster]

    provisioner "local-exec" {
    command = "mkdir -p ${var.cluster_config_path}"
  }

  provisioner "local-exec" {
    command = "/bin/bash ../scripts/cp4ba-clusteradmin-install.sh"
//    command = "/bin/bash ../scripts/cp4ba-clusteradmin-setup.sh"

    environment = {
      # Cluster
      //    enable = true
//    openshift_version   = var.openshift_version
//    cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_dir
    cluster_name_id     = var.cluster_name_id
//    on_vpc              = var.on_vpc

    // IBM Cloud API Key
    ibmcloud_api_key = var.ibmcloud_api_key

    # Cluster
//    on_vpc                        = var.on_vpc
//    portworx_is_ready             = var.portworx_is_ready
    namespace                     = local.cp4ba_namespace
//
//    # Platform
    platform_options               = local.platform_options
    platform_version              = local.platform_version
    project_name                  = local.project_name
    deployment_type               = local.deployment_type

    username_email                = var.entitled_registry_user_email
    use_entitlement               = local.use_entitlement
    entitlement_key               = entitlement_key # file("${path.cwd}/../../entitlement.key")
    # Registry Images
    local_public_registry_server  = var.public_registry_server
    local_public_image_registry   = var.public_image_registry
    local_registry_server         = var.registry_server
    local_registry_user           = var.registry_user
    local_registry_password       = var.registry_password
//    # Storage Classes
    storage_class_name            = local.storage_class_name
    sc_slow_file_storageclassname   = local.sc_slow_file_storage_classname
    sc_medium_file_storage_classname = local.sc_medium_file_storage_classname
    sc_fast_file_storage_classname   = local.sc_fast_file_storage_classname
////      on_vpc                        = var.on_vpc
//      portworx_is_ready             = var.portworx_is_ready
//      namespace                     = var.namespace
//
//      # Platform
//      Platform_Option               = var.platform_options
//      Platform_Version              = var.platform_version
//      Project_Name                  = var.project_name
//      Deployment_Type               = var.deployment_type
//      Username_Email                = var.entitled_registry_user_email
//      Use_Entitlement               = local.use_entitlement
//      Entitlement_Key               = local.entitled_registry_key
//      # Registry Images
//      Local_Public_Registry_Server  = var.public_registry_server
//      Local_Public_Image_Registry   = var.public_image_registry
//      Local_Registry_Server         = var.registry_server
//      Local_Registry_User           = var.registry_user
//      Local_Registry_Password       = var.registry_password
//      # Storage Classes
//      Storage_Class_Name               = local.storage_class_name
//      Sc_Slow_File_Storage_Classname   = local.sc_slow_file_storage_classname
//      Sc_Medium_File_Storage_Classname = local.sc_medium_file_storage_classname
//      Sc_Fast_File_Storage_Classname   = local.sc_fast_file_storage_classname
    }
  }
}