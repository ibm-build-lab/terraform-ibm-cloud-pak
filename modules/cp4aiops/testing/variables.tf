variable "region" {}
variable "resource_group_name" {}
variable "cluster_id" {}

variable "enable" {
  default     = true
  type        = bool
  description = "If set to true installs Cloud-Pak for Data on the given cluster"
}

variable "cluster_config_path" {
  type        = string
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "on_vpc" {
  default     = false
  type        = bool
  description = "If set to true, lets the module know cluster is using VPC Gen2"
}

variable "portworx_is_ready" {
  type    = any
  default = null
}

variable "openshift_version" {
  default     = "4.7"
  type        = string
  description = "Openshift version installed in the cluster"
}

variable "entitled_registry_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Docker email address"
}

variable "namespace" {
  type        = string
  description = "namespace for cp4aiop"
}
