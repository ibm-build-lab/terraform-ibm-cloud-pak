// Requirements:

// Module:

// TODO: With Terraform 0.13 replace the parameter 'enable' or the conditional expression using 'with_cp4mcm' with 'count'
module "cp4mcm" {
  source = "./.."
  enable = true

  // ROKS cluster parameters:
  openshift_version   = var.openshift_version
  cluster_config_path = ".kube/config" //data.ibm_container_cluster_config.cluster_config.config_file_path

  // Entitled Registry parameters:
  // 1. Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary
  // 2. Save the key to a file, update the file path in the entitled_registry_key parameter
  entitled_registry_key        = var.entitlement //file("${path.cwd}/../../entitlement.key")
  entitled_registry_user_email = var.entitled_registry_user_email

  on_vpc                       = true
  install_infr_mgt_module      = local.install_infr_mgt_module
  install_monitoring_module    = local.install_monitoring_module
  install_security_svcs_module = local.install_security_svcs_module
  install_operations_module    = local.install_operations_module
  install_tech_prev_module     = local.install_tech_prev_module
}

// Output variables:

output "namespace" {
  value = module.cp4mcm.namespace
}
output "endpoint" {
  value = module.cp4mcm.endpoint
}
output "user" {
  value = module.cp4mcm.user
}
output "password" {
  value = module.cp4mcm.password
}
