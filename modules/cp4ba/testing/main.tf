# Provider block
provider "ibm" {
  region           = var.region
  version          = "~> 1.12.0"
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
  config_dir        = "./kube/config"
  admin             = false
  network           = false
}

# getting and creation a directory for the cluster config file
resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
    provisioner "local-exec" {
    command = "mkdir -p ${var.cluster_config_path}"
  }
}

module "cp4ba"{
    source = "../.."
    // TODO: With Terraform 0.13 replace the parameter 'enable' or the conditional expression using 'with_iaf' with 'count'
    enable = true

    openshift_version   = var.openshift_version
    cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_dir
    cluster_name_id     = var.cluster_name_id
//    on_vpc              = var.on_vpc

    // IBM Cloud API Key
    ibmcloud_api_key = var.ibmcloud_api_key

    # Cluster
//    on_vpc                        = var.on_vpc
    portworx_is_ready             = var.portworx_is_ready
    namespace                     = var.namespace

    # Platform
    Platform_Option               = var.platform_options
    Platform_Version              = var.platform_version
    Project_Name                  = var.project_name
    Deployment_Type               = var.deployment_type

    Username_Email                = var.entitled_registry_user_email
    Use_Entitlement               = local.use_entitlement
    Entitlement_Key               = file("${path.cwd}/../../entitlement.key")
    # Registry Images
    Local_Public_Registry_Server  = local.local_public_registry_server
    Local_Public_Image_Registry   = local.local_public_image_registry
    Local_Registry_Server         = local.local_registry_server
    Local_Registry_User           = local.local_registry_user
    Local_Registry_Password       = local.local_registry_password
    # Storage Classes
    Storage_Class_Name            = local.storage_class_name
    Sc_Slow_File_Storage_Classname   = local.sc_slow_file_storage_classname
    Sc_Medium_File_Storage_Classname = local.sc_medium_file_storage_classname
    Sc_Fast_File_Storage_Classname   = local.sc_fast_file_storage_classname
}




