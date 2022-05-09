provider "ibm" {
}

// Module:
module "odf" {
  source = "./../../modules/odf"
  cluster = var.cluster
  ibmcloud_api_key = var.ibmcloud_api_key
  roks_version = var.roks_version

  // ODF parameters
  monSize = var.monSize
  monStorageClassName = var.monStorageClassName
  osdStorageClassName = var.osdStorageClassName
  osdSize = var.osdSize
  numOfOsd = var.numOfOsd
  billingType = var.billingType
  ocsUpgrade = var.ocsUpgrade
  clusterEncryption = var.clusterEncryption
}
