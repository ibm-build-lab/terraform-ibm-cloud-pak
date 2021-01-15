locals {
  cs_catalogsource_content = templatefile("../templates/CS_CatalogSource.yaml.tmpl", {
    openshift_version_number = local.openshift_version_number
  })
  mgt_catalogsource_content = templatefile("../templates/MGT_CatalogSource.yaml.tmpl", {
    openshift_version_number = local.openshift_version_number
  })
  installation_content = templatefile("../templates/Installation.yaml.tmpl", {
    namespace                    = "cp4mcm",
    install_infr_mgt_module      = local.install_infr_mgt_module,
    install_monitoring_module    = local.install_monitoring_module,
    install_security_svcs_module = local.install_security_svcs_module,
    install_operations_module    = local.install_operations_module,
    install_tech_prev_module     = local.install_tech_prev_module
  })
  cs_subscription_file     = "../files/CS_Subscription.yaml"
  cs_subscription_content  = file(local.cs_subscription_file)
  mgt_subscription_file    = "../files/MGT_Subscription.yaml"
  mgt_subscription_content = file(local.mgt_subscription_file)
  commonservice_file       = "../files/CommonService.yaml"
  commonservice_content    = file(local.commonservice_file)
}

resource "local_file" "CS_CatalogSource" {
  content  = local.cs_catalogsource_content
  filename = "${path.module}/rendered_files/CS_CatalogSource.yaml"
}
resource "local_file" "MGT_CatalogSource" {
  content  = local.mgt_catalogsource_content
  filename = "${path.module}/rendered_files/MGT_CatalogSource.yaml"
}
resource "local_file" "Installation" {
  content  = local.installation_content
  filename = "${path.module}/rendered_files/Installation.yaml"
}
resource "local_file" "CS_Subscription" {
  content  = local.cs_subscription_content
  filename = "${path.module}/rendered_files/CS_Subscription.yaml"
}
resource "local_file" "MGT_Subscription" {
  content  = local.mgt_subscription_content
  filename = "${path.module}/rendered_files/MGT_Subscription.yaml"
}
resource "local_file" "CommonService" {
  content  = local.commonservice_content
  filename = "${path.module}/rendered_files/CommonService.yaml"
}

locals {
  install_infr_mgt_module      = false
  install_monitoring_module    = false
  install_security_svcs_module = false
  install_operations_module    = false
  install_tech_prev_module     = false
}

