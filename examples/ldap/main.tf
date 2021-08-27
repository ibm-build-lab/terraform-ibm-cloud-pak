provider "ibm" {
  ibmcloud_api_key   = var.ibmcloud_api_key
  region = var.region
  ibmcloud_api_key   = var.ibmcloud_api_key
  iaas_classic_api_key   = var.iaas_classic_api_key
  iaas_classic_username = var.iaas_classic_username
}

module "ldap" {
  source = "../../modules/ldap"
  enable               = true
  hostname             = var.hostname
  ibmcloud_domain      = var.ibmcloud_domain
  os_reference_code    = var.os_reference_code
  datacenter           = var.datacenter
  network_speed        = var.network_speed
  hourly_billing       = var.hourly_billing
  private_network_only = var.private_network_only
  cores                = var.cores
  memory               = var.memory
  disks                = var.disks
  local_disk           = var.local_disk
}
