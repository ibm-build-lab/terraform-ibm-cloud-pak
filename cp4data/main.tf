// Requirements for CPD v3.0
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

// Requirements for CPD 3.5
locals {
  storage_class_file = {
    "ibmc-file-custom-gold-gid" = join("/", [path.module, "files", "sc_ibmc_file_custom_gold_gid.yaml"])
    "portworx-shared-gp3"       = ""
  }
  storage_class_content = file(local.storage_class_file[var.storage_class_name])

  security_context_constraints_content = templatefile("${path.module}/templates/security_context_constraints.tmpl.yaml", {
    namespace = local.namespace,
  })

  installer_sensitive_data = templatefile("${path.module}/templates/installer_sensitive_data.tmpl.yaml", {
    namespace                        = local.namespace,
    docker_username_encoded          = base64encode(local.docker_username),
    docker_registry_password_encoded = base64encode(local.entitled_registry_key),
  })

  installer_job_content = templatefile("${path.module}/templates/installer_job.tmpl.yaml", {
    namespace          = local.namespace,
    storage_class_name = var.storage_class_name,
    docker_registry    = local.docker_registry,

    // Modules to deploy
    install_WKC         = var.install_WKC,
    install_WSL         = var.install_WSL,
    install_WML         = var.install_WML,
    install_AIOPENSCALE = var.install_AIOPENSCALE,
    install_DV          = var.install_DV,
    install_STREAMS     = var.install_STREAMS,
    install_CDE         = var.install_CDE,
    install_SPARK       = var.install_SPARK,
    install_DB2WH       = var.install_DB2WH,
    install_DATAGATE    = var.install_DATAGATE,
    install_RSTUDIO     = var.install_RSTUDIO,
    install_DMC         = var.install_DMC,

    // install_guardium_external_stap                 = var.install_guardium_external_stap,
    // install_watson_assistant                       = var.install_watson_assistant,
    // install_watson_assistant_for_voice_interaction = var.install_watson_assistant_for_voice_interaction,
    // install_watson_discovery                       = var.install_watson_discovery,
    // install_watson_knowledge_studio                = var.install_watson_knowledge_studio,
    // install_watson_language_translator             = var.install_watson_language_translator,
    // install_watson_speech_text                     = var.install_watson_speech_text,
    // install_edge_analytics                         = var.install_edge_analytics,
  })
}

locals {
  installer_filename = {
    "3.0" = "./install_cp4data_3.0.sh"
    "3.5" = "./install_cp4data_3.5.sh"
  }
}

resource "null_resource" "install_cp4data" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1 = sha1(local.namespace)
    repo_sha1      = sha1(local.repo_content)
  }

  depends_on = [
    local_file.repo,
    var.install_version,
  ]

  provisioner "local-exec" {
    command     = local.installer_filename[var.install_version]
    working_dir = "${path.module}/scripts"

    environment = {
      KUBECONFIG           = var.cluster_config_path
      NAMESPACE            = local.namespace
      STORAGE_CLASS_NAME   = var.storage_class_name
      DOCKER_REGISTRY_PASS = local.entitled_registry_key
      DOCKER_USER_EMAIL    = var.entitled_registry_user_email
      DOCKER_USERNAME      = local.docker_username
      DOCKER_REGISTRY      = local.docker_registry

      // Parameters for CPD v3.0
      REPO_FILE = join("/", [path.module, "scripts", "repo.yaml"])

      // Parameters for CPD v3.5
      STORAGE_CLASS_CONTENT    = local.storage_class_content
      INSTALLER_SENSITIVE_DATA = local.installer_sensitive_data
      INSTALLER_JOB_CONTENT    = local.installer_job_content
      SCC_ZENUID_CONTENT       = local.security_context_constraints_content
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
