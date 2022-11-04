variable "region" {
  description = "Region that cluster resides in"
}

variable "resource_group_name" {
  default     = "Default"
  description = "Resource group that cluster resides in"
}

variable "cluster_id" {
  description = "Id of cluster for Cloud Pak to be installed on"
}

variable "enable" {
  default     = true
  type        = bool
  description = "If set to true installs Cloud-Pak for Network Automation on the given cluster"
}

variable "cluster_config_path" {
  default     = "./.kube/config"
  type        = string
  description = "Defaulted to `./.kube/config` but for schematics, use `/tmp/.schematic/.kube/config`"
}

variable "entitled_registry_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Docker email address"
}
