##################################
# Install ODF on the cluster
##################################

locals {
  installation_content = templatefile("${path.module}/templates/install_odf.yaml.tmpl", {
    roks_version = var.roks_version,
    monSize = var.monSize,
    monStorageClassName = var.monStorageClassName,
    monDevicePaths = var.monDevicePaths,
    autoDiscoverDevices = var.autoDiscoverDevices,
    osdSize = var.osdSize,
    osdStorageClassName = var.osdStorageClassName,
    osdDevicePaths = var.osdDevicePaths,
    numOfOsd = var.numOfOsd, 
    billingType = var.billingType,
    ocsUpgrade = var.ocsUpgrade,
    clusterEncryption = var.clusterEncryption,
    hpcsEncryption = var.hpcsEncryption,
    hpcsServiceName = var.hpcsServiceName,
    hpcsInstanceId = var.hpcsInstanceId,
    hpcsBaseUrl = var.hpcsBaseUrl,
    hpcsTokenUrl = var.hpcsTokenUrl,
    hpcsSecretName = var.hpcsSecretName
  })
}

# Install ODF if the rocks version is v4.7 or newer
resource "null_resource" "enable_odf" {
  
  triggers = {
    IC_API_KEY = var.ibmcloud_api_key
    CLUSTER = var.cluster
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = "${path.module}/scripts/install_odf.sh"

    environment = {
      IC_API_KEY = var.ibmcloud_api_key
      CLUSTER = var.cluster
      ROKS_VERSION = var.roks_version
      ODF_CR_CONTENT = local.installation_content
    }
  }

  provisioner "local-exec" {
    when        = destroy

    interpreter = ["/bin/bash", "-c"]
    command = "${path.module}/scripts/uninstall_odf.sh"

    environment = {
      IC_API_KEY = self.triggers.IC_API_KEY
      CLUSTER = self.triggers.CLUSTER
    }
  }
}
