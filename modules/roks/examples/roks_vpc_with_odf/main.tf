provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
}

# locals {
#   enable_cluster = var.cluster_id == null || var.cluster_id == ""
# }

module "cluster" {
  source = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/roks"
  enable = true
  on_vpc = true

  // General
  project_name   = var.project_name
  owner          = var.owner
  environment    = var.environment
  resource_group = var.resource_group
  roks_version   = var.roks_version
  entitlement    = var.entitlement
  force_delete_storage = var.force_delete_storage

  // Parameters for the Workers
  flavors        = var.flavors
  workers_count  = var.workers_count
  vpc_zone_names = var.vpc_zone_names
}

  
# Install ODF if the rocks version is v4.7 or newer
module "odf" {
  source = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/odf"

  cluster = module.cluster.id
  ibmcloud_api_key = var.ibmcloud_api_key
  roks_version = var.roks_version

  // ODF parameters
  monSize = var.monSize
  monStorageClassName = var.monStorageClassName
  monDevicePaths = var.monDevicePaths
  autoDiscoverDevices = var.autoDiscoverDevices
  osdSize = var.osdSize
  osdStorageClassName = var.osdStorageClassName
  osdDevicePaths = var.osdDevicePaths
  numOfOsd = var.numOfOsd
  billingType = var.billingType
  ocsUpgrade = var.ocsUpgrade
  clusterEncryption = var.clusterEncryption
  hpcsEncryption = var.hpcsEncryption
  hpcsServiceName = var.hpcsServiceName
  hpcsInstanceId = var.hpcsInstanceId
  hpcsBaseUrl = var.hpcsBaseUrl
  hpcsTokenUrl = var.hpcsTokenUrl
  hpcsSecretName = var.hpcsSecretName
}
