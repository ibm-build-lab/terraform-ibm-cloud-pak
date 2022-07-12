provider "ibm" {
  region = var.region
}

resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}

data "ibm_resource_group" "rg" {
  name = var.resource_group
}

module "classic-openshift-single-zone-cluster" {
  source = "terraform-ibm-modules/cluster/ibm//modules/classic-openshift-single-zone"

  // Openshift parameters:
  cluster_name          = local.cluster_name
  worker_zone           = var.worker_zone
  hardware              = var.hardware
  resource_group_id     = data.ibm_resource_group.rg.id
  worker_nodes_per_zone = (var.workers_count != null ? var.workers_count : 1)
  worker_pool_flavor    = (var.worker_pool_flavor != null ? var.worker_pool_flavor : null)
  public_vlan           = (var.public_vlan != null ? var.public_vlan : null)
  private_vlan          = (var.private_vlan != null ? var.private_vlan : null)
  kube_version          = local.roks_version
  tags                  = ["project:${var.project_name}", "env:${var.environment}", "owner:${var.owner}"]
  entitlement           = (var.entitlement != null ? var.entitlement : "")
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "mkdir -p ${var.config_dir}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on        = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = module.classic-openshift-single-zone-cluster.classic_openshift_cluster_id
  resource_group_id = data.ibm_resource_group.rg.id
  config_dir        = var.config_dir
  admin             = true
}

// Module:
module "cp4i" {
  source = "../.."

  // ROKS cluster parameters:
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  storageclass        = var.storage_class

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email
}
