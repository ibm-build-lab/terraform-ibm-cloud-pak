// Requirements

provider "ibm" {
//  version    = "~> 1.13"
  region     = var.region
}

// Module

locals {
  enable = length(var.cluster_id) == 0
}

module "cluster" {
  source = "../../modules/roks"
  enable = local.enable
  on_vpc = var.on_vpc

  // General
  project_name   = var.project_name
  owner          = var.owner
  environment    = var.environment
  resource_group = var.resource_group
  roks_version   = var.roks_version
  entitlement    = var.entitlement
  force_delete_storage = var.force_delete_storage

  // Parameters for Kubernetes Config
  // download_config = length(var.config_dir) > 0
  // config_dir      = var.config_dir
  // config_admin    = false
  // config_network  = false

  // Temporary, until the issue with the API permissions issues is fixed
  private_vlan_number = var.private_vlan_number
  public_vlan_number  = var.public_vlan_number

  // Parameters for the Workers
  flavors        = var.flavors
  workers_count  = var.workers_count
  datacenter     = var.datacenter
  vpc_zone_names = var.vpc_zone_names
}

// Test Output Parameters

output "endpoint" {
  value = module.cluster.endpoint
}

output "id" {
  value = module.cluster.id
}

output "name" {
  value = module.cluster.name
}

// output "config" {
//   value = module.cluster.config
// }

// output "config_file_path" {
//   value = data.ibm_container_cluster_config.cluster_config.config_file_path
// }

output "vlan_number" {
  value = module.cluster.vlan_number
}
