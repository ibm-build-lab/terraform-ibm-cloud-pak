// Requirements:

provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${var.cluster_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on        = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.group.id
  config_dir        = var.cluster_config_path
}

# Get classic cluster ingress_hostname for output
data "ibm_container_cluster" "cluster" {
  count           = ! var.on_vpc ? 1 : 0
  cluster_name_id = var.cluster_id
}

# Get vpc cluster ingress_hostname for output
data "ibm_container_vpc_cluster" "cluster" {
  count           = var.on_vpc ? 1 : 0
  cluster_name_id = var.cluster_id
}

// Module:
module "cp4data" {
  source = "../../modules/cp4data_4.0"
  enable = true

  // ROKS cluster parameters:
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc
  portworx_is_ready   = 1 // Assuming portworx is installed if using VPC infrastructure

  // Prereqs
  worker_node_flavor = var.worker_node_flavor

  operator_namespace = var.operator_namespace

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // CP4D License Acceptance
  accept_cpd_license = var.accept_cpd_license

  // CP4D Info
  cpd_project_name = "zen"

  # OP_NAMESPACE="ibm-common-services"

  // IBM Cloud API Key
  ibmcloud_api_key = var.ibmcloud_api_key

  region              = var.region
  resource_group_name = var.resource_group_name
  cluster_id          = var.cluster_id

  // Parameters to install submodules

  install_wsl         = var.install_wsl
  install_aiopenscale = var.install_aiopenscale
  install_wml         = var.install_wml
  install_wkc         = var.install_wkc
  install_dv          = var.install_dv
  install_spss        = var.install_spss
  install_cde         = var.install_cde
  install_spark       = var.install_spark
  install_dods        = var.install_dods
  install_ca          = var.install_ca
  install_ds          = var.install_ds
  install_db2oltp     = var.install_db2oltp
  install_db2wh       = var.install_db2wh
  install_big_sql     = var.install_big_sql
  install_wsruntime   = var.install_wsruntime

  storage_option      = var.storage_option

}
