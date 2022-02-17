##################################
# Install ODF on the cluster
##################################

# Install ODF if the rocks version is v4.7 or newer
resource "null_resource" "enable_odf" {
  count = var.enable ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = "${path.module}/scripts/install_odf.sh"

    environment = {
      IC_API_KEY = var.ibmcloud_api_key
      CLUSTER = var.cluster
    }
  }
}