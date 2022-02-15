locals {
  setAIOPS_catalog_source = "aiops-catalog.yaml"
}

###########################################
# Preinstallation Steps for AIOPS
###########################################

resource "null_resource" "create_namespace" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.cluster_config_path
    }
    interpreter = ["/bin/bash", "-c"]
    command     = "kubectl create namespace ${var.namespace}"
  }
}

resource "null_resource" "create_entitlement_account" {
  depends_on = [null_resource.create_namespace]

  provisioner "local-exec" {
    command     = "./create_entitlement.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.namespace
      ENTITLEMENT_KEY               = var.entitlement_key
    }
  }
}

resource "null_resource" "configure_network_policies" {
  depends_on = [null_resource.create_entitlement_account]
  
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.cluster_config_path
    }
    interpreter = ["/bin/bash", "-c"]
    command     = "if [ $(kubectl get ingresscontroller default -n openshift-ingress-operator -o jsonpath='{.status.endpointPublishingStrategy.type}') = \"HostNetwork\" ]; then oc patch namespace default --type=json -p '[{\"op\":\"add\",\"path\":\"/metadata/labels\",\"value\":{\"network.openshift.io/policy-group\":\"ingress\"}}]'; fi"
  }
}

resource "null_resource" "create_catalog_source" {
  depends_on = [null_resource.configure_network_policies]
  
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.cluster_config_path
    }
    working_dir = "${path.module}/files/"
    interpreter = ["/bin/bash", "-c"]
    command     = "kubectl apply -f ${local.setAIOPS_catalog_source}"
  }
}

###########################################
# Create and configure storage
###########################################
resource "null_resource" "install_portworx_sc" {
  depends_on = [null_resource.configure_network_policies]

  # Install portworx storage classes on cluster if it's VPC
  count = var.on_vpc ? 1 : 0

  provisioner "local-exec" {
    command     = "./px-aiops.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      KUBECONFIG = var.cluster_config_path
    }
  }
}

#######################
# Catch-all checkpoint
#######################
resource "null_resource" "prereqs_checkpoint" {
  depends_on = [
    var.portworx_is_ready,
    null_resource.create_namespace,
    null_resource.create_entitlement_account,
    null_resource.configure_network_policies,
    null_resource.create_catalog_source,
    null_resource.install_portworx_sc
  ]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = "echo '=== REACHED PREREQS CHECKPOINT ==='"
  }
}