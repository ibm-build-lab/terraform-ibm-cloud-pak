variable "on_vpc" {
  type        = bool
  default     = false
  description = "if true the ROKS cluster will be created in IBM Cloud VPC, otherwise will be Classic"
  // default     = "true"
}

variable "enable" {
  default     = true
  description = "If set to true installs IBM Automation Foundation on the given cluster"
}

variable "cluster_config_path" {
  description = "Path to the Kubernetes configuration file to access your cluster"
}

// variable "cluster_config" {
//   type = object({
//     host               = string
//     client_certificate = string
//     client_key         = string
//     token              = string
//     config_file_path   = string
//   })
//   description = "Kubernetes configuration parameters such as host, certificates or token to access your cluster"
// }

variable "cluster_name_id" {
  default = ""
  description = "Name or id of the cluster"
}

variable "openshift_version" {
  description = "Openshift version installed in the cluster"
}

variable "entitled_registry_key" {
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  description = "Docker email address"
}

locals {
  iaf_namespace            = "iaf"
  entitled_registry        = "cp.icr.io"
  entitled_registry_user   = "cp"
  entitled_registry_key    = chomp(var.entitled_registry_key)
  openshift_version_regex  = regex("(\\d+).(\\d+)(.\\d+)*(_openshift)*", var.openshift_version)
  openshift_version_number = local.openshift_version_regex[3] == "_openshift" ? tonumber("${local.openshift_version_regex[0]}.${local.openshift_version_regex[1]}") : 0
}
