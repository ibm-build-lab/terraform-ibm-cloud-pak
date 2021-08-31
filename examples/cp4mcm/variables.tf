
variable "ibmcloud_api_key" {
  description = "IBMCloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "cluster_id" {
  description = "ROKS cluster id. Use the ROKS terraform module or other way to create it"
}

variable "on_vpc" {
  type = bool
  default = false
  description = "Is cluster a VPC cluster"
}

variable "entitled_registry_user_email" {
  type = string
  description = "Email address of the owner of the Entitled Registry Key"
}

variable "entitled_registry_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}


variable "resource_group" {
  default     = "Default"
  type        = string
  description = "resource group where the cluster is running"
}

variable "install_infr_mgt_module" {
  default     = false
  description = "Install Infrastructure Management module"
}

variable "install_monitoring_module" {
  type = bool
  default     = false
  description = "Install Monitoring module"
}

variable "install_security_svcs_module" {
  type = bool
  default     = false
  description = "Install Security Services module"
}

variable "install_operations_module" {
  type = bool
  default     = false
  description = "Install Operations module"
}

variable "install_tech_prev_module" {
  type = bool
  default     = false
  description = "Install Tech Preview module"
}

locals {
  namespace = "cp4mcm"
  config_dir = "./.kube/config"
}
