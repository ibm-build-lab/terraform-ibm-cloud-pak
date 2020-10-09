locals {
  catalogsource_content = templatefile("../templates/CatalogSource.yaml.tmpl", {
    openshift_version_number = local.openshift_version_number,
  })
  installation_content = templatefile("../templates/Installation.yaml.tmpl", {
    namespace                    = "cp4mcm",
    install_infr_mgt_module      = local.install_infr_mgt_module,
    install_monitoring_module    = local.install_monitoring_module,
    install_security_svcs_module = local.install_security_svcs_module,
    install_operations_module    = local.install_operations_module,
    install_tech_prev_module     = local.install_tech_prev_module
  })
  subscription_file    = "../files/Subscription.yaml"
  subscription_content = file(local.subscription_file)
}

resource "local_file" "CatalogSource" {
  content  = local.catalogsource_content
  filename = "${path.module}/rendered_files/CatalogSource.yaml"
}
resource "local_file" "Installation" {
  content  = local.installation_content
  filename = "${path.module}/rendered_files/Installation.yaml"
}
resource "local_file" "Subscription" {
  content  = local.subscription_content
  filename = "${path.module}/rendered_files/Subscription.yaml"
}

locals {
  install_infr_mgt_module      = false
  install_monitoring_module    = false
  install_security_svcs_module = false
  install_operations_module    = false
  install_tech_prev_module     = false
}

