# Provider block
provider "ibm" {
  region           = var.region
  version          = "~> 1.12"
  ibmcloud_api_key = var.ibmcloud_api_key
}


// user output and pwd outputs

# Getting the OpenShift cluster configuration
data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${var.config_dir}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_name_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = true
  config_dir        = ".kube/config"
  admin             = false
  network           = false
}

module "cp4ba"{
    source = "git::https://github.com/jgod1360/terraform-ibm-cloud-pak/blob/cp4ba/modules/cp4ba/"
   // source = ".././"
   
//    CLUSTER_NAME_OR_ID     = var.cluster_name_or_id
    //    on_vpc              = var.on_vpc

        // IBM Cloud API Key
      IBMCLOUD_API_KEY = var.ibmcloud_api_key

      # Cluster
  //    on_vpc                        = var.on_vpc
  //    portworx_is_ready             = var.portworx_is_ready
  //    namespace                     = local.cp4ba_namespace
  //
  //    # Platform
      PLATFORM_SELECTED              = local.platform_options
      PLATFORM_VERSION              = local.platform_version
      PROJECT_NAME                     = local.project_name
      DEPLOYMENT_TYPE               = local.deployment_type
      USER_NAME_EMAIL                = var.entitled_registry_user_email
      USE_ENTITLEMENT               = local.use_entitlement
      ENTITLED_REGISTRY_KEY               = var.entitlement_key # file("${path.cwd}/../../entitlement.key")
      # Registry Images
      DOCKER_SECRET_NAME            = var.docker_secret_name
      DOCKER_SERVER                 = local.docker_server
      DOCKER_USERNAME               = local.docker_username
      DOCKER_REGISTRY_PASS               = local.docker_password
      DOCKER_USER_EMAIL                  = local.docker_email
      public_registry_server        = var.public_registry_server
      LOCAL_PUBLIC_REGISTRY_SERVER   = var.public_image_registry
  //    local_registry_server         = var.registry_server
  //    local_registry_user           = var.registry_user

  //    # Storage Classes
      STORAGE_CLASSNAME            = local.storage_class_name
      SC_SLOW_FILE_STORAGE_CLASSNAME   = local.sc_slow_file_storage_classname
      SC_MEDIUM_FILE_STORAGE_CLASSNAME = local.sc_medium_file_storage_classname
      SC_FAST_FILE_STORAGE_CLASSNAME   = local.sc_fast_file_storage_classname
}




