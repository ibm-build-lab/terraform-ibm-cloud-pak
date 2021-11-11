variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for AIOPS on the given cluster"
}

variable "cluster_config_path" {
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "on_vpc" {
  default     = false
  type        = bool
  description = "If set to true, lets the module know cluster is using VPC"
}

variable "entitled_registry_key" {
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  description = "Docker email address"
}

variable "namespace" {
  default     = "cp4aiops"
  description = "Namespace for Cloud Pak for Integration"
}

locals {
  docker_registry = "cp.icr.io"
  docker_username = "cp"
}
