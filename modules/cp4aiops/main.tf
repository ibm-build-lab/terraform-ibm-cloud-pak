locals {
  on_vpc_ready = var.on_vpc ? var.portworx_is_ready : 1

  # TODO, add additional aiops features from default
  storageclass = {
    "ldap"        = var.on_vpc ? "portworx-aiops" : "ibmc-file-gold-gid",
    "persistence" = var.on_vpc ? "portworx-aiops" : "ibmc-file-gold-gid",
    # "zen"         = var.on_vpc ? "portworx-aiops" : "ibmc-file-gold-gid",
    "topology"    = var.on_vpc ? "portworx-aiops" : "ibmc-file-gold-gid"
  }
}

###########################################
# Installation Steps for AIOPS - AIManager
###########################################

resource "null_resource" "install_aiops_operator" {
  count = var.enable_aimanager ? 1 : 0
  depends_on = [
    local.on_vpc_ready,
    null_resource.prereqs_checkpoint
  ]

  provisioner "local-exec" {
    command     = "./install_aiops_operator.sh"
    working_dir = "${path.module}/scripts/aimanager/"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.namespace
    }
  }
}

resource "null_resource" "install_cp4aiops" {
  depends_on = [
    null_resource.install_aiops_operator
  ]
  
  triggers = {
    namespace_sha1                      = sha1(var.namespace)
    docker_params_sha1                  = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
  }

  provisioner "local-exec" {
    command     = "./install_cp4aiops.sh"
    working_dir = "${path.module}/scripts/aimanager/"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.namespace
      ON_VPC                        = var.on_vpc
      DOCKER_REGISTRY_PASS          = var.entitled_registry_key
      DOCKER_USER_EMAIL             = var.entitled_registry_user_email
      DOCKER_USERNAME               = local.docker_username
      DOCKER_REGISTRY               = local.docker_registry
    }
  }
}

resource "null_resource" "configure_cert_nginx" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_cp4aiops
  ]

  provisioner "local-exec" {
    command     = "./update_cert.sh"
    working_dir = "${path.module}/scripts/aimanager"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.namespace
    }
  }
}

###########################################
# Installation Steps for AIOPS - EventManager
###########################################

resource "null_resource" "install_event_manager_operator" {
  count = var.enable_event_manager ? 1 : 0
  depends_on = [
    local.on_vpc_ready,
    null_resource.prereqs_checkpoint,
    null_resource.configure_cert_nginx
  ]

  provisioner "local-exec" {
    command     = "./install_noi_operator.sh"
    working_dir = "${path.module}/scripts/eventmanager/"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.namespace
    }
  }
}

resource "null_resource" "install_event_manager" {

  provisioner "local-exec" {
    command     = "./install_event_manager.sh"
    working_dir = "${path.module}/scripts/eventmanager/"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.namespace
      ACCEPT_LICENSE                = var.accept_aiops_license
      PERSISTENT_SC                 = local.storageclass["persistence"]
      TOPOLOGY_SC                   = local.storageclass["topology"]
      LDAP_SC                       = local.storageclass["ldap"]
      ENABLE_PERSISTENCE            = var.enable_persistence
    }
  }

  depends_on = [
    null_resource.install_event_manager_operator
  ]
}

data "external" "get_endpoints" {
  depends_on = [
    null_resource.install_cp4aiops,
    null_resource.install_event_manager
  ]

  program = ["/bin/bash", "${path.module}/scripts/aimanager/get_endpoints.sh"]

  query = {
    KUBECONFIG = var.cluster_config_path
    NAMESPACE  = var.namespace
  }
}


