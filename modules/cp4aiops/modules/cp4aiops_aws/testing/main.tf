// Module:
module "cp4aiops" {
  source = "./.."
  enable = var.enable

  // ROKS cluster parameters:
  cluster_config_path = var.cluster_config_path
  on_vpc              = var.on_vpc

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  namespace = var.namespace
}