
provider "ibm" {
  version    = "~> 1.12"
  region     = var.region
}

provider "kubernetes" {
  config_path = local.config_dir
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

