locals {
  repo_content = templatefile("${path.module}/templates/repo.tmpl.yaml", {
    entitled_registry_key                          = local.entitled_registry_key,
    docker_id                                      = var.docker_id,
    docker_access_token                            = var.docker_access_token,
    install_guardium_external_stap                 = var.install_guardium_external_stap,
    install_watson_assistant                       = var.install_watson_assistant,
    install_watson_assistant_for_voice_interaction = var.install_watson_assistant_for_voice_interaction,
    install_watson_discovery                       = var.install_watson_discovery,
    install_watson_knowledge_studio                = var.install_watson_knowledge_studio,
    install_watson_language_translator             = var.install_watson_language_translator,
    install_watson_speech_text                     = var.install_watson_speech_text,
    install_edge_analytics                         = var.install_edge_analytics,
  })
}

resource "local_file" "repo" {
  content  = local.repo_content
  filename = "${path.module}/scripts/repo.yaml"
}

resource "null_resource" "install_cp4data" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1 = sha1(local.namespace)
    repo_sha1      = sha1(local.repo_content)
  }

  depends_on = [
    local_file.repo,
  ]

  provisioner "local-exec" {
    command     = "./install_cp4data.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      KUBECONFIG         = var.cluster_config_path
      NAMESPACE          = local.namespace
      STORAGE_CLASS_NAME = var.storage_class_name
    }
  }
}

// data "external" "get_endpoints" {
//   count = var.enable ? 1 : 0

//   depends_on = [
//     null_resource.install_cp4data,
//   ]

//   program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

//   query = {
//     kubeconfig = var.cluster_config_path
//     namespace  = local.namespace
//   }
// }

// TODO: It may be considered in a future version to pass the cluster ID and the
// resource group to get the cluster configuration and store it in memory and in
// a directory, either specified by the user or in the module local directory

// variable "resource_group" {
//   default     = "default"
//   description = "List all available resource groups with: ibmcloud resource groups"
// }
// data "ibm_resource_group" "group" {
//   name = var.resource_group
// }
// data "ibm_container_cluster_config" "cluster_config" {
//   cluster_name_id   = var.cluster_id
//   resource_group_id = data.ibm_resource_group.group.id
// }
