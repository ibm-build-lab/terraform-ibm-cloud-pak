locals {
  setOpenshiftServerless_file = "openshift-serverless.yaml"
  setKnativeServing_file = "knative-serving.yaml"
  setKnativeEventing_file = "knative-eventing.yaml"
  setStrimzi_file = "strimzi-subscription.yaml"

}

###########################################
# Create Knative Options and disable route
###########################################

resource "null_resource" "openshift_serverless" {
  depends_on = [var.portworx_is_ready]
  
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.cluster_config_path
    }
    working_dir = "${path.module}/files/"
    interpreter = ["/bin/bash", "-c"]
    command = "oc apply -f ${local.setOpenshiftServerless_file} && sleep 120"
  }
}

resource "null_resource" "knative_serving" {
  depends_on = [null_resource.openshift_serverless]
  
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.cluster_config_path
    }
    working_dir = "${path.module}/files/"
    interpreter = ["/bin/bash", "-c"]
    command = "oc apply -f ${local.setKnativeServing_file} && sleep 60"
  }
}

resource "null_resource" "knative_eventing" {
  depends_on = [null_resource.knative_serving]
  
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.cluster_config_path
    }
    working_dir = "${path.module}/files/"
    interpreter = ["/bin/bash", "-c"]
    command = "oc apply -f ${local.setKnativeEventing_file} && sleep 60"
  }
}

resource "null_resource" "disable_knative_route" {
  depends_on = [null_resource.knative_eventing]

  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.cluster_config_path
    }
    interpreter = ["/bin/bash", "-c"]
    command = "oc annotate service.serving.knative.dev/kn-cli -n knative-serving serving.knative.openshift.io/disableRoute=true"
  }
}

###########################################
# Install Strimzi
###########################################
resource "null_resource" "strimzi_subscription" {
  depends_on = [null_resource.knative_eventing]
  
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = var.cluster_config_path
    }
    working_dir = "${path.module}/files/"
    interpreter = ["/bin/bash", "-c"]
    command = "oc apply -f ${local.setStrimzi_file} && sleep 120"
  }
}

###########################################
# Create and configure storage
###########################################
resource "null_resource" "install_portworx_sc" {
  depends_on = [null_resource.strimzi_subscription]

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

resource "null_resource" "install_db2_local" {
  depends_on = [null_resource.strimzi_subscription]

  provisioner "local-exec" {
    command     = "./install_db2_local.sh"
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
    null_resource.openshift_serverless,
    null_resource.knative_serving,
    null_resource.knative_eventing,
    null_resource.disable_knative_route,
    null_resource.strimzi_subscription,
    null_resource.install_portworx_sc,
    null_resource.install_db2_local,
  ]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = "echo '=== REACHED PREREQS CHECKPOINT ==='"
  }
}