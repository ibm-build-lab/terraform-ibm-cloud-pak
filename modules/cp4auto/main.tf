locals {

  ibm_operator_catalog       = file(join("/", [path.module, "files", "ibm-operator-catalog.yaml"]))
  opencloud_operator_catalog = file(join("/", [path.module, "files", "opencloud-operator-catalog.yaml"]))
  pvc_claim                  = file(join("/", [path.module, "files", "pvc.yaml"]))
  services_subscription      = file(join("/", [path.module, "files", "common-services-subscription.yaml"]))
  cp4a_subscription          = file(join("/", [path.module, "files", "cp4a-subscription.yaml"]))

}

#  security_context_constraints_content = templatefile("${path.module}/templates/security_context_constraints.tmpl.yaml", {
#    namespace = local.namespace,
#  })


resource "null_resource" "install_cp4auto" {
  count = var.enable ? 1 : 0

  triggers = {
    force_to_run                    = var.force ? timestamp() : 0
    namespace_sha1                  = sha1(local.namespace)
    docker_params_sha1              = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    ibm_operator_catalog_sha1       = sha1(local.ibm_operator_catalog)
    opencloud_operator_catalog_sha1 = sha1(local.opencloud_operator_catalog)
    services_subscription_sha1      = sha1(local.services_subscription)
    cp4a_subscription_sha1          = sha1(local.cp4a_subscription)
    pvc_claim_sha1                  = sha1(local.pvc_claim)
    #security_context_constraints_content_sha1 = sha1(local.security_context_constraints_content)
    #installer_sensitive_data_sha1             = sha1(local.installer_sensitive_data)
    #installer_job_content_sha1                = sha1(local.installer_job_content)
  }

  provisioner "local-exec" {
    command     = "./install_cp4auto.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      FORCE                      = var.force
      KUBECONFIG                 = var.cluster_config_path
      NAMESPACE                  = local.namespace
      IBM_OPERATOR_CATALOG       = local.ibm_operator_catalog
      OPENCLOUD_OPERATOR_CATALOG = local.opencloud_operator_catalog
      SERVICES_SUBSCRIPTION      = local.services_subscription
      CP4A_SUBSCRIPTION          = local.cp4a_subscription
      PVC_CLAIM                  = local.pvc_claim
      DOCKER_REGISTRY_PASS       = local.entitled_registry_key
      DOCKER_USER_EMAIL          = var.entitled_registry_user_email
      DOCKER_USERNAME            = local.docker_username
      DOCKER_REGISTRY            = local.docker_registry
      #INSTALLER_SENSITIVE_DATA      = local.installer_sensitive_data
      #INSTALLER_JOB_CONTENT         = local.installer_job_content
      #SCC_ZENUID_CONTENT            = local.security_context_constraints_content
      // DEBUG                    = true
    }
  }
}

# data "external" "get_endpoints" {
#   count = var.enable ? 1 : 0

#   depends_on = [
#     null_resource.install_cp4i,
#   ]

#   program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

#   query = {
#     kubeconfig = var.cluster_config_path
#     namespace  = local.namespace
#   }
# }

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
