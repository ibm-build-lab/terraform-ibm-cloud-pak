locals {
  # These are the the yamls that will be pulled from the ./files  these will be used to start hte operator
  catalog_content = templatefile("${path.module}/templates/catalog.yaml.tmpl", {
    namespace = var.namespace
  })
  subscription_content = templatefile("${path.module}/templates/subscription.yaml.tmpl", {
    namespace = var.namespace
  })
  navigator_content = templatefile("${path.module}/templates/navigator.yaml.tmpl", {
    storageclass = var.storageclass
  })
}

# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_cp4i" {
  count = var.enable ? 1 : 0

  triggers = {
    namespace_sha1               = sha1(var.namespace)
    docker_params_sha1           = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    catalog_sha1                 = sha1(local.catalog_content)
    subscription_sha1            = sha1(local.subscription_content)
    navigator_sha1               = sha1(local.navigator_content)
  }

  provisioner "local-exec" {
    command     = "./install_cp4i.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.namespace
      STORAGECLASS                  = var.storageclass
      CATALOG_CONTENT               = local.catalog_content
      SUBSCRIPTION_CONTENT          = local.subscription_content
      NAVIGATOR_CONTENT             = local.navigator_content
      DOCKER_REGISTRY_PASS          = local.entitled_registry_key
      DOCKER_USER_EMAIL             = var.entitled_registry_user_email
      DOCKER_USERNAME               = local.entitled_registry_user
      DOCKER_REGISTRY               = local.entitled_registry
    }
  }
}

data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_cp4i
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.namespace
  }
}
