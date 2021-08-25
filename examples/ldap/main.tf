provider "ibm" {
  version          = "~> 1.12"
  region = var.region
  iaas_classic_api_key   = var.iaas_classic_api_key
  iaas_classic_username = var.iaas_classic_username
}

module "ldap" {
  source = "../../modules/ldap"
  enable               = true
  hostname             = var.hostname
  ibmcloud_domain      = var.ibmcloud_domain
  os_reference_code    = "CentOS_8_64"
  datacenter           = var.datacenter
  network_speed        = var.network_speed
  hourly_billing       = var.hourly_billing
  private_network_only = var.private_network_only
  cores                = var.cores
  memory               = var.memory
  disks                = var.disks
  local_disk           = var.local_disk
}
