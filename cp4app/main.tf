locals {
  icpa_installer_job_content = templatefile("${path.module}/templates/icpa_installer_job.tmpl.yaml", {
    icpa_namespace         = local.icpa_namespace,
    icpa_installer_image   = local.icpa_installer_image,
    entitled_registry      = local.entitled_registry,
    entitled_registry_user = local.entitled_registry_user,
    entitled_registry_key  = local.entitled_registry_key,
    installer_command      = var.installer_command
  })
}

resource "null_resource" "install_icpa" {
  count = var.enable ? 1 : 0

  triggers = {
    icpa_namespace                     = sha1(local.icpa_namespace)
    entitled_registry_sha1             = sha1(join("", [local.entitled_registry_user, local.entitled_registry_key, var.entitled_registry_user_email, local.entitled_registry]))
    icpa_installer_patch_sha1          = sha1(file(join("/", [path.module, "files", "patch.sh"]))),
    icpa_installer_job_sha1            = sha1(local.icpa_installer_job_content)
    icpa_kubeconfig_content_sha1       = sha1(file(var.cluster_config_path))
    config_file_content_sha1           = sha1(file(join("/", [path.module, "files", "data", "config.yaml"]))),
    kabanero_file_content_sha1         = sha1(file(join("/", [path.module, "files", "data", "kabanero.yaml"]))),
    transadv_file_content_sha1         = sha1(file(join("/", [path.module, "files", "data", "transadv.yaml"]))),
    mobilefoundation_file_content_sha1 = sha1(file(join("/", [path.module, "files", "data", "mobilefoundation.yaml"]))),
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/install_cp4app.sh"

    environment = {
      KUBECONFIG                        = var.cluster_config_path
      ICPA_NAMESPACE                    = local.icpa_namespace
      ICPA_ENTITLED_REGISTRY_USER       = local.entitled_registry_user
      ICPA_ENTITLED_REGISTRY_KEY        = local.entitled_registry_key
      ICPA_ENTITLED_REGISTRY_USER_EMAIL = var.entitled_registry_user_email
      ICPA_ENTITLED_REGISTRY            = local.entitled_registry
      ICPA_INSTALLER_PATCH_FILE         = join("/", [path.module, "files", "patch.sh"])
      ICPA_DATA_CONFIG_DIR              = join("/", [path.module, "files", "data"])
      ICPA_INSTALLER_JOB_CONTENT        = local.icpa_installer_job_content
    }
  }
}

data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_icpa,
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
  }
}
