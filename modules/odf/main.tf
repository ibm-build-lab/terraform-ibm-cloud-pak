##################################
# Install ODF on the cluster
##################################

# Install ODF if the rocks version is v4.7 or newer
resource "null_resource" "enable_odf" {
  count = var.enable && var.roks_version != "4.6" ? 1 : 0

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kube_config_path
    }

    interpreter = ["/bin/bash", "-c"]
    command = "ibmcloud oc cluster addon enable openshift-data-foundation -c ${var.cluster} --version 4.8.0 --param \"odfDeploy=true\""
  }
}
