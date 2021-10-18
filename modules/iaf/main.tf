locals {
  catalogsource_content = templatefile("${path.module}/templates/CatalogSource.yaml.tmpl", {
  })
  automationbase_content = templatefile("${path.module}/templates/AutomationBase.yaml.tmpl", {
    namespace = local.iaf_namespace
  })
  subscription_content = templatefile("${path.module}/templates/Subscription.yaml.tmpl", {
    namespace = local.iaf_namespace
  })
}

resource "null_resource" "install_iaf" {
  count = var.enable ? 1 : 0

  triggers = {
    docker_credentials_sha1 = sha1(join("", [local.entitled_registry_user, var.entitled_registry_key, var.entitled_registry_user_email, local.entitled_registry, local.iaf_namespace]))
    catalogsource_sha1      = sha1(local.catalogsource_content)
    subscription_sha1       = sha1(local.subscription_content)
    automationbase_sha1     = sha1(local.automationbase_content)
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/set_pull_secrets.sh"

    environment = {
      KUBECONFIG                       = var.cluster_config_path
      IAF_CLUSTER                      = var.cluster_name_id
      REGION                           = var.region
      RESOURCE_GROUP                   = var.resource_group
      IAF_CLUSTER_ON_VPC               = var.on_vpc
      IC_API_KEY                       = local.ibmcloud_api_key
      IAF_ENTITLED_REGISTRY_USER       = local.entitled_registry_user
      IAF_ENTITLED_REGISTRY_KEY        = local.entitled_registry_key
      IAF_ENTITLED_REGISTRY_USER_EMAIL = var.entitled_registry_user_email
      IAF_ENTITLED_REGISTRY            = local.entitled_registry
    }
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/install_iaf.sh"

    environment = {
      KUBECONFIG                = var.cluster_config_path
      IAF_NAMESPACE             = local.iaf_namespace
      IAF_CATALOGSOURCE_CONTENT = local.catalogsource_content
      IAF_SUBSCRIPTION_CONTENT  = local.subscription_content
      IAF_INSTALLATION_CONTENT  = local.automationbase_content
    }
  }
}
