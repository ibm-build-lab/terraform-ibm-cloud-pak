# This section checks to see if the values have been updated through out the script running and is required for any dynamic value
resource "null_resource" "install_cp4i" {

  triggers = {
    namespace_sha1     = sha1(var.namespace)
    docker_params_sha1 = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
    catalog_sha1       = sha1(local.catalog_content)
    subscription_sha1  = sha1(local.subscription_content)
    navigator_sha1     = sha1(local.navigator_content)
    kubeconfig         = var.cluster_config_path
    namespace          = var.namespace
  }

  provisioner "local-exec" {
    command     = "./install_cp4i.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      KUBECONFIG           = var.cluster_config_path
      NAMESPACE            = var.namespace
      STORAGECLASS         = var.storageclass
      CATALOG_CONTENT      = local.catalog_content
      SUBSCRIPTION_CONTENT = local.subscription_content
      NAVIGATOR_CONTENT    = local.navigator_content
      DOCKER_REGISTRY_PASS = local.entitled_registry_key
      DOCKER_USER_EMAIL    = var.entitled_registry_user_email
      DOCKER_USERNAME      = local.entitled_registry_user
      DOCKER_REGISTRY      = local.entitled_registry
    }
  }

  provisioner "local-exec" {
    when        = destroy
    command     = "./uninstall_cp4i.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
      NAMESPACE  = self.triggers.namespace
    }
  }
}

data "external" "get_endpoints" {

  depends_on = [
    null_resource.install_cp4i
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.namespace
  }
}
