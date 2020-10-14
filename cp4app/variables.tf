variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for Applications on the given cluster"
}

variable "entitled_registry_key" {
  description = "Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary and save the key to this variable"
}
variable "entitled_registry_user_email" {
  description = "Docker email address"
}

variable "cluster_config_path" {
  default     = "~/.kube/config"
  description = "location of the kubernetes config file"
}

variable "cp4app_installer_comand" {
  default     = "install"
  description = "Command to execute by the icpa installer, the most common are: install, uninstall, check, upgrade"
}

// variable "data_directory" {
//   default     = "./data"
//   description = "directory used by the CP4App installer to store all the AP4App configuration files"
// }

locals {
  icpa_namespace         = "icpa-installer"
  entitled_registry      = "cp.icr.io"
  entitled_registry_user = "cp"
  entitled_registry_key  = chomp(var.entitled_registry_key)
  icpa_installer_image   = "icpa-installer:4.2.1"
}
