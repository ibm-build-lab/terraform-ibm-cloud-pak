terraform {
  required_version = ">=0.13"
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      version    = "~> 1.12"
//       region     = var.region
//       ibmcloud_api_key = var.ibmcloud_api_key
    }
  }
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

data "ibm_iam_api_key" "iam_api_key" {
    apikey_id = var.ibmcloud_api_key
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${local.cluster_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.group.id
  config_dir        = local.cluster_config_path
}

provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}

// Module:
module "cp4aiops" {
  source    = "../../modules/cp4aiops"
  enable    = true
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc
  portworx_is_ready   = 1          // Assuming portworx is installed if using VPC infrastructure

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // AIOps specific parameters:
  namespace           = "cp4aiops"
}
