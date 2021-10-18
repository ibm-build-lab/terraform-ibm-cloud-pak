variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for security on the given cluster"
}

variable "force" {
  default     = false
  description = "Force the execution. Useful to execute the job again"
}

variable "cluster_config_path" {
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "openshift_version" {
  default     = "4.7"
  description = "Openshift version installed in the cluster"
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
variable "entitled_registry_user_email" {
  description = "Docker email address"
}

variable "namespace" {
  default = "cp4s"
  description = "Namespace for Cloud Pak for Network Automation"
}

variable "entitled_registry_key" {
  description = "ibm cloud pak entitlement key"
}

variable "admin_user" {
  default = "default_user"
  description = "user to be given administartor privileges in the default account"
}

locals {
  namespace                = "cp4s"
  entitled_registry        = "cp.icr.io"
  entitled_registry_user   = "cp"
  docker_registry          = "cp.icr.io" // Staging: "cp.stg.icr.io/cp/cpd"
  docker_username          = "cp"               // "ekey"
  entitled_registry_key    = chomp(var.entitled_registry_key)
}
