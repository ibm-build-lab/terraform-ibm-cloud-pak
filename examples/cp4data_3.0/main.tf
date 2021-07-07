provider "ibm" {
  generation = local.infra == "classic" ? 1 : 2
  region     = var.region
}

locals {
  enable_cluster = var.cluster_id == null || var.cluster_id == ""
}

module "cluster" {
  // source = "../../../../ibm-hcbt/terraform-ibm-cloud-pak/roks"
  source = "../../modules/roks"
  enable = local.enable_cluster
  on_vpc = local.infra == "vpc"

  // General parameters:
  project_name = var.project_name
  owner        = var.owner
  environment  = var.environment

  // Openshift parameters:
  resource_group       = var.resource_group
  roks_version         = local.roks_version
  flavors              = local.flavors
  workers_count        = local.workers_count
  datacenter           = var.datacenter
  force_delete_storage = true

  // Kubernetes Config parameters:
  // download_config = false
  // config_dir      = local.kubeconfig_dir
  // config_admin    = false
  // config_network  = false

  // Debugging
  private_vlan_number = var.private_vlan_number
  public_vlan_number  = var.public_vlan_number
}

resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "mkdir -p ${local.kubeconfig_dir}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]

  cluster_name_id   = local.enable_cluster ? module.cluster.id : var.cluster_id
  resource_group_id = module.cluster.resource_group.id
  config_dir        = local.kubeconfig_dir
  download          = true
  admin             = false
  network           = false
}

// TODO: With Terraform 0.13 replace the parameter 'enable' with 'count'
module "cp4data" {
  // source = "../../../../ibm-hcbt/terraform-ibm-cloud-pak/cp4data_3.0"
  source = "../.../modules/cp4data_3.0"
  enable = true

  // ROKS cluster parameters:
  openshift_version   = local.roks_version
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path

  // Entitled Registry parameters:
  entitled_registry_key        = length(var.entitled_registry_key) > 0 ? var.entitled_registry_key : file(local.entitled_registry_key_file)
  entitled_registry_user_email = var.entitled_registry_user_email

  // Parameters to install CPD modules
  docker_id                                      = var.docker_id
  docker_access_token                            = var.docker_access_token
  install_guardium_external_stap                 = var.install_guardium_external_stap
  install_watson_assistant                       = var.install_watson_assistant
  install_watson_assistant_for_voice_interaction = var.install_watson_assistant_for_voice_interaction
  install_watson_discovery                       = var.install_watson_discovery
  install_watson_knowledge_studio                = var.install_watson_knowledge_studio
  install_watson_language_translator             = var.install_watson_language_translator
  install_watson_speech_text                     = var.install_watson_speech_text
  install_edge_analytics                         = var.install_edge_analytics
}
