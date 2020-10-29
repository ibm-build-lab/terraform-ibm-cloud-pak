// Requirements

provider "ibm" {
  version    = "~> 1.13"
  generation = var.infra == "classic" ? 1 : 2
  region     = var.region
}

// Module

locals {
  enable = length(var.cluster_id) == 0
}

module "cluster" {
  source = "./.."
  enable = local.enable
  on_vpc = var.infra == "vpc"

  // General
  project_name   = var.project_name
  owner          = var.owner
  environment    = var.environment
  resource_group = var.resource_group
  roks_version   = var.roks_version

  // Parameters for Kubernetes Config
  // download_config = length(var.config_dir) > 0
  // config_dir      = var.config_dir
  // config_admin    = false
  // config_network  = false

  // Parameters for the Workers
  flavors        = local.flavors
  workers_count  = local.workers_count
  datacenter     = var.datacenter
  vpc_zone_names = local.vpc_zone_names
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
