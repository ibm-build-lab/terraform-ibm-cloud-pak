
variable "on_vpc" {
  type        = bool
  default     = false
  description = "if true the ROKS cluster will be created in IBM Cloud VPC, otherwise will be Classic"
}

variable "cluster_id" {
  description = "ROKS cluster id. Use the ROKS terraform module or other way to create it"
}

variable "region" {
  description = "Region of the cluster"
}

variable "resource_group_name" {
  description = "Resource group that the cluster is created in"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Email address of the user owner of the Entitled Registry Key"
}

variable "entitled_registry_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

// ROKS Module : Local Variables and constants
locals {
  kube_config_path = "./.kube/config"
}
