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

# variable "cluster_endpoint" {
#   default     = "not-required"
#   description = "URL to access the OpenShift cluster"
# }

variable "entitled_registry_key" {
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  description = "Docker email address"
}

// Modules available to install on CP4D

variable "empty_module_list" {
  default     = true
  type        = bool
  description = "Determine if any modules need to be installed for CP4D"
}
variable "install_watson_knowledge_catalog" {
  default     = false
  type        = bool
  description = "Install Watson Knowledge Catalog module. Only for Cloud Pak for Data v3.5"
}
variable "install_watson_studio" {
  default     = false
  type        = bool
  description = "Install Watson Studio module. Only for Cloud Pak for Data v3.5"
}
variable "install_watson_machine_learning" {
  default     = false
  type        = bool
  description = "Install Watson Machine Learning module. Only for Cloud Pak for Data v3.5"
}
variable "install_watson_open_scale" {
  default     = false
  type        = bool
  description = "Install Watson Open Scale module. Only for Cloud Pak for Data v3.5"
}
variable "install_data_virtualization" {
  default     = false
  type        = bool
  description = "Install Data Virtualization module. Only for Cloud Pak for Data v3.5"
}
variable "install_streams" {
  default     = false
  type        = bool
  description = "Install Streams module. Only for Cloud Pak for Data v3.5"
}
variable "install_analytics_dashboard" {
  default     = false
  type        = bool
  description = "Install Analytics Dashboard module. Only for Cloud Pak for Data v3.5"
}
variable "install_spark" {
  default     = false
  type        = bool
  description = "Install Analytics Engine powered by Apache Spark module. Only for Cloud Pak for Data v3.5"
}
variable "install_db2_warehouse" {
  default     = false
  type        = bool
  description = "Install DB2 Warehouse module. Only for Cloud Pak for Data v3.5"
}
variable "install_db2_data_gate" {
  default     = false
  type        = bool
  description = "Install DB2 Data_Gate module. Only for Cloud Pak for Data v3.5"
}
variable "install_rstudio" {
  default     = false
  type        = bool
  description = "Install RStudio module. Only for Cloud Pak for Data v3.5"
}
variable "install_db2_data_management" {
  default     = false
  type        = bool
  description = "Install DB2 Data Management module. Only for Cloud Pak for Data v3.5"
}

locals {
  namespace                = "default"
  entitled_registry        = "cp.icr.io"
  entitled_registry_user   = "cp"
  docker_registry          = "cp.icr.io" // Staging: "cp.stg.icr.io/cp/cpd"
  docker_username          = "cp"               // "ekey"
  entitled_registry_key    = chomp(var.entitled_registry_key)
  openshift_version_regex  = regex("(\\d+).(\\d+)(.\\d+)*(_openshift)*", var.openshift_version)
  openshift_version_number = local.openshift_version_regex[3] == "_openshift" ? tonumber("${local.openshift_version_regex[0]}.${local.openshift_version_regex[1]}") : 0
}
