variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for Data on the given cluster"
}


variable "cluster_config_path" {
  description = "Path to the Kubernetes configuration file to access your cluster"
}


variable "on_vpc" {
  default     = false
  type        = bool
  description = "If set to true, lets the module know cluster is using VPC Gen2"
}

variable "portworx_is_ready" {
  type = any
  default = null
}

variable "entitlement_key" {
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user" {
  description = "Docker email address"
}

variable "namespace" {
  default = "cpaiops"
  description = "Namespace for Cloud Pak for AIOps"
}

variable "accept_aiops_license" {
  default = false
  type = bool
  description = "Do you accept the licensing agreement for aiops? `T/F`"
}

variable "enable_aimanager" {
  default = true
  type = bool
  description = "Install AIManager? `T/F`"
}

variable "enable_event_manager" {
  default = true
  type = bool
  description = "Install Event Manager? `T/F`"
}

#############################################
# Event Manager Options
#############################################
variable "enable_persistence" {
  default = true
  type = bool
  description = "Enables persistence storage for kafka, cassandra, couchdb, and others. Default is `true`"
}

locals {
  docker_registry          = "cp.icr.io" // Staging: "cp.stg.icr.io/cp/cpd"
  docker_username          = "cp"               // "ekey"
  entitled_registry_key    = chomp(var.entitlement_key)
}
