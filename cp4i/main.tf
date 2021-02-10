locals {

  ibm_operator_catalog_file = {
    "ibm-operator-catalog" = join("/", [path.module, "files", "ibm-operator-catalog.yaml"])
    "portworx-shared-gp3"  = ""
  }
  ibm_operator_catalog_content = file(local.ibm_operator_catalog_file[var.ibm_operator_catalog_name]) 

  opencloud_operator_catalog_file = {
    "opencloud-operator-catalog" = join("/", [path.module, "files", "opencloud-operator-catalog.yaml"])
    "portworx-shared-gp3"  = ""
  }
  opencloud_operator_catalog_content = file(local.ibm_operator_catalog_file[var.ibm_operator_catalog_name]) 

  subscription_file = {
    "ibm-operator-catalog" = join("/", [path.module, "files", "subscription.yaml"])
    "portworx-shared-gp3"  = ""
  }
  subscription_content = file(local.ibm_operator_catalog_file[var.ibm_operator_catalog_name]) 


#  security_context_constraints_content = templatefile("${path.module}/templates/security_context_constraints.tmpl.yaml", {
#    namespace = local.namespace,
#  })

  installer_sensitive_data = templatefile("${path.module}/templates/installer_sensitive_data.tmpl.yaml", {
    namespace                        = local.namespace,
    docker_username_encoded          = base64encode(local.docker_username),
    docker_registry_password_encoded = base64encode(local.entitled_registry_key),
  })

#   installer_job_content = templatefile("${path.module}/templates/installer_job.tmpl.yaml", {
#     namespace          = local.namespace,
#     storage_class_name = var.storage_class_name,
#     docker_registry    = local.docker_registry,
#   })
# }

resource "null_resource" "install_cp4i" {
  count = var.enable ? 1 : 0

  triggers = {
    force_to_run                              = var.force ? timestamp() : 0
    namespace_sha1                            = sha1(local.namespace)
    docker_params_sha1                        = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    ibm_operator_catalog_content_sha1         = sha1(local.storage_class_content)
    opencloud_operator_catalog_content_sha1   = sha1(local.storage_class_content)
    subscription_content_sha1                 = sha1(local.storage_class_content)
    #security_context_constraints_content_sha1 = sha1(local.security_context_constraints_content)
    installer_sensitive_data_sha1             = sha1(local.installer_sensitive_data)
    installer_job_content_sha1                = sha1(local.installer_job_content)
  }

  provisioner "local-exec" {
    command     = "./install_cp4i.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      FORCE                         = var.force
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = local.namespace
      IBM_OPERATOR_CATALOG          = var.ibm_operator_catalog_name
      OPENCLOUD_OPERATOR_CATALOG    = var.opencloud_operator_catalog_name
      SUBSCRIPTION                  = var.subscription_name
      DOCKER_REGISTRY_PASS          = local.entitled_registry_key
      DOCKER_USER_EMAIL             = var.entitled_registry_user_email
      DOCKER_USERNAME               = local.docker_username
      DOCKER_REGISTRY               = local.docker_registry
      IBM_OPERATOR_CATALOG_CONTENT  = var.ibm_operator_catalog_content
      OPENCLOUD_OPERATOR_CATALOG_CONTENT = var.opencloud_operator_catalog_content
      SUBSCRIPTION_CONTENT          = var.subscription_content
      INSTALLER_SENSITIVE_DATA      = local.installer_sensitive_data
      INSTALLER_JOB_CONTENT         = local.installer_job_content
      SCC_ZENUID_CONTENT            = local.security_context_constraints_content
      // DEBUG                    = true
    }
  }
}

data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_cp4i,
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = local.namespace
  }
}

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
