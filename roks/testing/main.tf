// Requirements

provider "ibm" {
  version    = "~> 1.13"
  generation = var.infra == "classic" ? 1 : 2
  region     = "us-south"
}

// Module

module "cluster" {
  source = "./.."
  on_vpc = var.infra == "classic" ? false : true

  // General
  project_name   = var.project_name
  owner          = var.owner
  environment    = var.environment
  resource_group = var.resource_group
  roks_version   = var.roks_version

  // Parameters for Kubernetes Config
  download_config = length(var.config_dir) > 0
  config_dir      = var.config_dir
  config_admin    = false
  config_network  = false

  // Parameters for IBM Cloud Classic
  datacenter          = var.datacenter
  size                = var.size
  flavor              = var.flavor
  private_vlan_number = var.private_vlan_number
  public_vlan_number  = var.public_vlan_number

  // Parameters for IBM Cloud VPC
  vpc_zone_names = local.vpc_zone_names
  flavors        = local.flavors
  workers_count  = local.workers_count
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

output "config" {
  value = module.cluster.config
}

output "config_file_path" {
  value = module.cluster.config.config_file_path
}
