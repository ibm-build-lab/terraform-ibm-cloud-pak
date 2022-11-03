#############################
# Optimize kernel parameters
#############################
locals {
  setkernelparams_file = local.worker_node_memory < 128 ? "setkernelparams.yaml" : "setkernelparams_128gbRAM.yaml"
  # set_norootsquash_file = "norootsquash.yaml"
  worker_node_memory = tonumber(regex("[0-9]+$", var.worker_node_flavor))
}

resource "null_resource" "setkernelparams" {
  depends_on = [var.odf_is_ready]

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.cluster_config_path
    }
    working_dir = "${path.module}/files/"
    interpreter = ["/bin/bash", "-c"]
    command     = "oc apply -n kube-system -f ${local.setkernelparams_file}"
  }
}

###########################################
# Create and annotate image registry route
###########################################
resource "null_resource" "create_registry_route" {
  depends_on = [
    var.odf_is_ready,
    null_resource.setkernelparams,
  ]
  
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.cluster_config_path
    }
    interpreter = ["/bin/bash", "-c"]
    command     = "oc create route reencrypt --service=image-registry -n openshift-image-registry"
  }
}
resource "null_resource" "annotate_registry_route" {
  depends_on = [null_resource.create_registry_route]

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.cluster_config_path
    }
    interpreter = ["/bin/bash", "-c"]
    command     = "oc annotate route image-registry --overwrite haproxy.router.openshift.io/balance=source -n openshift-image-registry"
  }
}


#######################
# Catch-all checkpoint
#######################
resource "null_resource" "prereqs_checkpoint" {
  depends_on = [
    var.odf_is_ready,
    null_resource.setkernelparams,
    null_resource.create_registry_route,
    null_resource.annotate_registry_route,
  ]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "echo '=== REACHED PREREQS CHECKPOINT ==='"
  }
}