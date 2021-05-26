variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for Multi Cloud Management on the given cluster"
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

variable "openshift_version" {
  description = "Openshift version installed in the cluster"
}

variable "on_vpc" {
  description = "Cluster type. VPC: on_vpc=true, Classic: on_vpc=false"
}

variable "ibmcloud_api_key" {
  description = "IBMCloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "entitled_registry_key" {
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  description = "Docker email address"
}

variable "install_infr_mgt_module" {
  default     = false
  description = "Install Infrastructure Management module"
}

variable "install_monitoring_module" {
  default     = false
  description = "Install Monitoring module"
}

variable "install_security_svcs_module" {
  default     = false
  description = "Install Security Services module"
}

variable "install_operations_module" {
  default     = false
  description = "Install Operations module"
}

variable "install_tech_prev_module" {
  default     = false
  description = "Install Tech Preview module"
}

locals {
  mcm_namespace            = "cp4mcm"
  entitled_registry        = "cp.icr.io"
  entitled_registry_user   = "cp"
  entitled_registry_key    = chomp(var.entitled_registry_key)
  ibmcloud_api_key         = chomp(var.ibmcloud_api_key)
  openshift_version_regex  = regex("(\\d+).(\\d+)(.\\d+)*(_openshift)*", var.openshift_version)
  openshift_version_number = local.openshift_version_regex[3] == "_openshift" ? tonumber("${local.openshift_version_regex[0]}.${local.openshift_version_regex[1]}") : 0
}
