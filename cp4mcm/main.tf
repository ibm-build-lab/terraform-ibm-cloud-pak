locals {
  cs_catalogsource_content = templatefile("${path.module}/templates/CS_CatalogSource.yaml.tmpl", {
    openshift_version_number = local.openshift_version_number
  })
  mgt_catalogsource_content = templatefile("${path.module}/templates/MGT_CatalogSource.yaml.tmpl", {
    openshift_version_number = local.openshift_version_number
  })
  installation_content = templatefile("${path.module}/templates/Installation.yaml.tmpl", {
    namespace                    = local.mcm_namespace,
    on_vpc                       = var.on_vpc,
    install_infr_mgt_module      = var.install_infr_mgt_module,
    install_monitoring_module    = var.install_monitoring_module,
    install_security_svcs_module = var.install_security_svcs_module,
    install_operations_module    = var.install_operations_module,
    install_tech_prev_module     = var.install_tech_prev_module
  })
  cs_subscription_file     = "${path.module}/files/CS_Subscription.yaml"
  cs_subscription_content  = file(local.cs_subscription_file)
  mgt_subscription_file    = "${path.module}/files/MGT_Subscription.yaml"
  mgt_subscription_content = file(local.mgt_subscription_file)
  commonservice_file       = "${path.module}/files/CommonService.yaml"
  commonservice_content    = file(local.commonservice_file)
}

resource "null_resource" "install_cp4mcm" {
  count = var.enable ? 1 : 0

  triggers = {
    docker_credentials_sha1 = sha1(join("", [local.entitled_registry_user, var.entitled_registry_key, var.entitled_registry_user_email, local.entitled_registry, local.mcm_namespace]))
    cs_catalogsource_sha1   = sha1(local.cs_catalogsource_content)
    cs_subscription_sha1    = sha1(local.cs_subscription_content)
    mgt_catalogsource_sha1  = sha1(local.mgt_catalogsource_content)
    mgt_subscription_sha1   = sha1(local.mgt_subscription_content)
    commonservice_sha1      = sha1(local.commonservice_content)
    installation_sha1       = sha1(local.installation_content)
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/install_cp4mcm.sh"

    environment = {
      KUBECONFIG                       = var.cluster_config_path
      MCM_NAMESPACE                    = local.mcm_namespace
      MCM_ENTITLED_REGISTRY_USER       = local.entitled_registry_user
      MCM_ENTITLED_REGISTRY_KEY        = local.entitled_registry_key
      MCM_ENTITLED_REGISTRY_USER_EMAIL = var.entitled_registry_user_email
      MCM_ENTITLED_REGISTRY            = local.entitled_registry
      MCM_CS_CATALOGSOURCE_CONTENT     = local.cs_catalogsource_content
      MCM_CS_SUBSCRIPTION_FILE         = local.cs_subscription_file
      MCM_MGT_CATALOGSOURCE_CONTENT    = local.mgt_catalogsource_content
      MCM_MGT_SUBSCRIPTION_FILE        = local.mgt_subscription_file
      MCM_COMMONSERVICE_FILE           = local.commonservice_file
      MCM_INSTALLATION_CONTENT         = local.installation_content
      MCM_WAIT_SEC                     = 30
    }
  }
}

data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_cp4mcm,
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
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
