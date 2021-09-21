module "cp4i" {
  source = "./.."
  enable = true

  // ROKS cluster parameters:
  cluster_config_path = var.config_file_path
  storageclass        = var.storageclass

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  namespace           = "cp4i"
}