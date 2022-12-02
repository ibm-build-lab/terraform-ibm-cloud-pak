provider "ibm" {
}

// Module:
module "odf" {
  source = "../."
  cluster = var.cluster
  ibmcloud_api_key = var.ibmcloud_api_key
  roks_version = var.roks_version

  // ODF parameters
  monSize = var.monSize
  monStorageClassName = var.monStorageClassName
  monDevicePaths = var.monDevicePaths
  autoDiscoverDevices = var.autoDiscoverDevices
  osdStorageClassName = var.osdStorageClassName
  osdSize = var.osdSize
  osdDevicePaths = var.osdDevicePaths
  numOfOsd = var.numOfOsd
  billingType = var.billingType
  ocsUpgrade = var.ocsUpgrade
  clusterEncryption = var.clusterEncryption
  #workerNodes = var.workerNodes
  hpcsEncryption = var.hpcsEncryption
  hpcsServiceName = var.hpcsServiceName
  hpcsInstanceId = var.hpcsInstanceId
  hpcsBaseUrl = var.hpcsBaseUrl
  hpcsTokenUrl = var.hpcsTokenUrl
  hpcsSecretName = var.hpcsSecretName
}
