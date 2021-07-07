provider "ibm" {
  generation = local.infra == "classic" ? 1 : 2
  region     = var.region
}

locals {
  enable_cluster = var.cluster_id == null || var.cluster_id == ""
}

module "cluster" {
  source = "../../modules/roks"
  enable = local.enable_cluster
  on_vpc = local.infra == "vpc"

  // General parameters:
  project_name = var.project_name
  owner        = var.owner
  environment  = var.environment

  // Openshift parameters:
  resource_group       = var.resource_group
  roks_version         = local.roks_version
  flavors              = local.flavors
  workers_count        = local.workers_count
  datacenter           = var.datacenter
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

data "ibm_resource_group" "group" {
  name = var.resource_group
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
  resource_group_id = data.ibm_resource_group.group.id
  config_dir        = local.kubeconfig_dir
  download          = true
  admin             = false
  network           = false
}

// TODO: With Terraform 0.13 replace the parameter 'enable' with 'count'
module "cp4app" {
  source = "../../modules/cp4app"
  enable = true

  cluster_config_path          = data.ibm_container_cluster_config.cluster_config.config_file_path
  entitled_registry_key        = length(var.entitled_registry_key) > 0 ? var.entitled_registry_key : file(local.entitled_registry_key_file)
  entitled_registry_user_email = var.entitled_registry_user_email
  installer_command            = var.installer_command
}
