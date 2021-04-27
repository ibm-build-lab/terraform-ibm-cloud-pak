locals {
  catalogsource_content = templatefile("${path.module}/templates/CatalogSource.yaml.tmpl", {
    openshift_version_number = local.openshift_version_number
  })
  automationbase_content = templatefile("${path.module}/templates/AutomationBase.yaml.tmpl", {
    namespace                    = local.iaf_namespace
  })
  subscription_content  = templatefile("${path.module}/templates/Subscription.yaml.tmpl", {
    namespace                    = local.iaf_namespace
  })
}

resource "null_resource" "install_iaf" {
  count = var.enable ? 1 : 0

  triggers = {
    docker_credentials_sha1 = sha1(join("", [local.entitled_registry_user, var.entitled_registry_key, var.entitled_registry_user_email, local.entitled_registry, local.iaf_namespace]))
    catalogsource_sha1   = sha1(local.catalogsource_content)
    subscription_sha1    = sha1(local.subscription_content)
    automationbase_sha1    = sha1(local.automationbase_content)
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/set_pull_secrets.sh"

    environment = {
      KUBECONFIG                       = var.cluster_config_path
      IAF_CLUSTER                      = var.cluster_name_id
      IAF_CLUSTER_ON_VPC               = var.on_vpc
      IAF_ENTITLED_REGISTRY_USER       = local.entitled_registry_user
      IAF_ENTITLED_REGISTRY_KEY        = local.entitled_registry_key
      IAF_ENTITLED_REGISTRY_USER_EMAIL = var.entitled_registry_user_email
      IAF_ENTITLED_REGISTRY            = local.entitled_registry
    }
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/install_iaf.sh"

    environment = {
      KUBECONFIG                       = var.cluster_config_path
      IAF_NAMESPACE                    = local.iaf_namespace
      IAF_CATALOGSOURCE_CONTENT        = local.catalogsource_content
      IAF_SUBSCRIPTION_CONTENT         = local.subscription_content
      IAF_INSTALLATION_CONTENT         = local.automationbase_content
    }
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
