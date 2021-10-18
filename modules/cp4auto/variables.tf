variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for Data on the given cluster"
}

variable "force" {
  default     = false
  description = "Force the execution. Useful to execute the job again"
}

variable "cluster_config_path" {
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "openshift_version" {
  default     = "4.5"
  description = "Openshift version installed in the cluster"
}

variable "entitled_registry_key" {
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  description = "Docker email address"
}


locals {
  namespace                = "default"
  entitled_registry        = "cp.icr.io"
  entitled_registry_user   = "cp"
  docker_registry          = "cp.icr.io" // Staging: "cp.stg.icr.io/cp/cpd"
  docker_username          = "cp"        // "ekey"
  entitled_registry_key    = chomp(var.entitled_registry_key)
  openshift_version_regex  = regex("(\\d+).(\\d+)(.\\d+)*(_openshift)*", var.openshift_version)
  openshift_version_number = local.openshift_version_regex[3] == "_openshift" ? tonumber("${local.openshift_version_regex[0]}.${local.openshift_version_regex[1]}") : 0
}
