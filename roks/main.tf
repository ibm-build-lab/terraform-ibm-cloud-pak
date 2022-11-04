
provider "ibm" {
  region = var.region
}

provider "kubernetes" {
  config_path = local.config_dir
}

module "cluster" {
  source = "./module"
  enable = local.enable
  on_vpc = var.on_vpc

  // General
  project_name         = var.project_name
  owner                = var.owner
  environment          = var.environment
  resource_group       = var.resource_group
  roks_version         = var.roks_version
  entitlement          = var.entitlement
  force_delete_storage = var.force_delete_storage

  // Parameters for the Workers
  flavors       = var.flavors
  workers_count = var.workers_count
  // Classic only
  datacenter          = var.datacenter
  private_vlan_number = var.private_vlan_number
  public_vlan_number  = var.public_vlan_number
  // VPC only
  vpc_zone_names = var.vpc_zone_names
}

