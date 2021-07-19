variable "region" {}
variable "resource_group_name" {}
variable "cluster_id" {}

variable "enable" {
  default     = true
  type        = bool
  description = "If set to true installs Cloud-Pak for Security on the given cluster"
}

variable "on_vpc" {
  default     = false
  type        = bool
  description = "If set to true, lets the module know cluster is using VPC Gen2"
}

variable "kube_config_path" {
  type        = string
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "entitled_registry_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Docker email address"
}

variable "ldap_status" {
  description = "true if client has an ldap, false if client does not have an ldap"
}

variable "ldap_user_id" {
  description = "value of ldap admin uid"
}


