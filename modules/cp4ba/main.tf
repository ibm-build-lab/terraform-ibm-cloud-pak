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

    environment = {
      # Cluster
      on_vpc                        = var.on_vpc
      portworx_is_ready             = var.portworx_is_ready
      namespace                     = var.namespace

      # Platform 
      Platform_Option               = var.platform_options
      Platform_Version              = var.platform_version
      Project_Name                  = var.project_name
      Deployment_Type               = var.deployment_type
      Username_Email                = var.entitled_registry_user_email
      Use_Entitlement               = local.use_entitlement
      Entitlement_Key               = local.entitled_registry_key
      # Registry Images
      Local_Public_Registry_Server  = local.local_public_registry_server
      Local_Public_Image_Registry   = local.local_public_image_registry
      Local_Registry_Server         = local.local_registry_server
      Local_Registry_User           = local.local_registry_user
      Local_Registry_Password       = local.local_registry_password
      # Storage Classes
      Storage_Class_Name               = local.storage_class_name
      Sc_Slow_File_Storage_Classname   = local.sc_slow_file_storage_classname
      Sc_Medium_File_Storage_Classname = local.sc_medium_file_storage_classname
      Sc_Fast_File_Storage_Classname   = local.sc_fast_file_storage_classname
    }
  }
}