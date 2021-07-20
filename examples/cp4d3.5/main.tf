// Requirements:

provider "ibm" {
  region = var.region
  version    = "~> 1.12"
}

data "ibm_resource_group" "group" {
  name = var.resource_group_name
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

# Get classic cluster ingress_hostname for output
data "ibm_container_cluster" "cluster" {
  count = var.enable && ! var.on_vpc ? 1 : 0
  cluster_name_id = var.cluster_id
}

# Get vpc cluster ingress_hostname for output
data "ibm_container_vpc_cluster" "cluster" {
  count = var.enable && var.on_vpc ? 1 : 0
  cluster_name_id = var.cluster_id
}

// Module:
module "cp4data" {
  source          = "../../modules/cp4data"
  enable          = var.enable

  // ROKS cluster parameters:
  openshift_version   = var.openshift_version
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc
  portworx_is_ready   = var.portworx_is_ready // only need if on_vpc = true

  // Prereqs
  worker_node_flavor = var.worker_node_flavor

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // CP4D License Acceptance
  accept_cpd_license = var.accept_cpd_license

  // CP4D Info
  cpd_project_name = var.cpd_project_name

  // Parameters to install submodules
  install_watson_knowledge_catalog = var.install_watson_knowledge_catalog
  install_watson_studio            = var.install_watson_studio
  install_watson_machine_learning  = var.install_watson_machine_learning
  install_watson_open_scale        = var.install_watson_open_scale
  install_data_virtualization      = var.install_data_virtualization
  install_streams                  = var.install_streams
  install_analytics_dashboard      = var.install_analytics_dashboard
  install_spark                    = var.install_spark
  install_db2_warehouse            = var.install_db2_warehouse
  install_db2_data_gate            = var.install_db2_data_gate
  install_big_sql                  = var.install_big_sql
  install_rstudio                  = var.install_rstudio
  install_db2_data_management      = var.install_db2_data_management
}