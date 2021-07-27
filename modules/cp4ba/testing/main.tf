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
//    source = "../."
    source = "/../."
    // TODO: With Terraform 0.13 replace the parameter 'enable' or the conditional expression using 'with_iaf' with 'count'
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
    platform_options              = local.platform_options
    platform_version              = local.platform_version
    project_name                  = local.project_name
    deployment_type               = local.deployment_type

    username_email                = var.entitled_registry_user_email
    use_entitlement               = local.use_entitlement
    entitlement_key               = var.entitlement_key # file("${path.cwd}/../../entitlement.key")
    # Registry Images
    local_public_registry_server  = var.public_registry_server
    local_public_image_registry   = var.public_image_registry
    local_registry_server         = var.registry_server
    local_registry_user           = var.registry_user
    local_registry_password       = var.registry_password
//    # Storage Classes
    storage_class_name               = local.storage_class_name
    sc_slow_file_storageclassname    = local.sc_slow_file_storage_classname
    sc_medium_file_storage_classname = local.sc_medium_file_storage_classname
    sc_fast_file_storage_classname   = local.sc_fast_file_storage_classname
}




