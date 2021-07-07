provider "ibm" {
  version    = "~> 1.12"
  region     = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
}

provider "kubernetes" {
  config_path = var.config_dir
}

locals {
  enable_cluster = var.cluster_id == null || var.cluster_id == ""
}

module "cluster" {
  source = "../../modules/roks"
  enable = local.enable_cluster
  on_vpc = var.on_vpc

  // General parameters:
  project_name = var.project_name
  owner        = var.owner
  environment  = var.environment

  // Openshift parameters:
  resource_group       = var.resource_group
  roks_version         = local.roks_version
  flavors              = var.flavors
  workers_count        = local.workers_count
  datacenter           = var.datacenter
  vpc_zone_names       = var.vpc_zone_names
  force_delete_storage = true

  // Kubernetes Config parameters:
  // download_config = false
  // config_dir      = local.kubeconfig_dir
  // config_admin    = false
  // config_network  = false

  // Debugging
  private_vlan_number = var.private_vlan_number
  public_vlan_number  = var.public_vlan_number
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "mkdir -p ${local.kubeconfig_dir}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]

  cluster_name_id   = local.enable_cluster ? module.cluster.id : var.cluster_id
  resource_group_id = module.cluster.resource_group.id
  config_dir        = local.kubeconfig_dir
  download          = true
  admin             = false
  network           = false
}

// TODO: With Terraform 0.13 replace the parameter 'enable' with 'count'
module "cp4mcm" {
  source = "../../modules/cp4mcm"
  enable = true
  on_vpc = var.on_vpc
  
  // IBM Cloud API Key
  ibmcloud_api_key          = var.ibmcloud_api_key

  // ROKS cluster parameters:
  openshift_version   = local.roks_version
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  cluster_name_id = local.enable_cluster ? module.cluster.id : var.cluster_id

  // Entitled Registry parameters:
  entitled_registry_key        = length(var.entitled_registry_key) > 0 ? var.entitled_registry_key : file(local.entitled_registry_key_file)
  entitled_registry_user_email = var.entitled_registry_user_email

  install_infr_mgt_module      = var.install_infr_mgt_module
  install_monitoring_module    = var.install_monitoring_module
  install_security_svcs_module = var.install_security_svcs_module
  install_operations_module    = var.install_operations_module
  install_tech_prev_module     = var.install_tech_prev_module
}
