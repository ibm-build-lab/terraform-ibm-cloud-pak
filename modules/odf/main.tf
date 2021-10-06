##################################
# Install ODF on the cluster
##################################

# Install ODF if the rocks version is v4.7 or newer
resource "null_resource" "enable_odf_4.7" {
  count = var.enable && var.roks_version != "4.6" ? 1 : 0

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.kube_config_path
    }

    interpreter = ["/bin/bash", "-c"]
    command = "ibmcloud oc cluster addon enable openshift-data-foundation -c ${var.cluster_id} --version 4.7.0 --param \"odfDeploy=true\""
  }
}

# Check the status of the OCS or ODF install operator
# TO-DO
# resource "null_resource" "check_install" {
#   count = var.enable && var.roks_version != "4.6" ? 1 : 0

#   depends_on = [
#     null_resource.enable_odf_4.7
#   ]

#   provisioner "local-exec" {
#     environment = {
#       KUBECONFIG = var.kube_config_path
#     }

#     working_dir = "${path.module}/scripts/"
#     interpreter = ["/bin/bash", "-c"]
#     command = "./check_odf_status.sh"
#   }
# }