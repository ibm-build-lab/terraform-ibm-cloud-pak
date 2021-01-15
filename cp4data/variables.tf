variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for Data on the given cluster"
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
  default     = "4.5"
  description = "Openshift version installed in the cluster"
}

// variable "cluster_endpoint" {
//   default     = "not-required"
//   description = "URL to access the OpenShift cluster"
// }

variable "entitled_registry_key" {
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  description = "Docker email address"
}

variable "storage_class_name" {
  default     = "ibmc-file-custom-gold-gid"
  description = "Storage Class name to use. Supported Storage Classes: ibmc-file-custom-gold-gid, portworx-shared-gp3"
}

// variable "cp4data_config_file" {
//   default = "./repo.yaml"
//   description = "location to "
// }

variable "install_version" {
  default     = "3.5"
  description = "version of Cloud Pak for Data to install. Supported versions: 3.0, 3.5"
}


// Modules available to install on CP4D v3.0

variable "install_guardium_external_stap" {
  default     = false
  description = "Install Guardium® External S-TAP® module. Only for Cloud Pak for Data v3.0"
}
variable "docker_id" {
  default     = ""
  description = "Docker ID required to install Guardium® External S-TAP® module. Only for Cloud Pak for Data v3.0"
}
variable "docker_access_token" {
  default     = ""
  description = "Docker access token required to install Guardium® External S-TAP® module. Only for Cloud Pak for Data v3.0"
}
variable "install_watson_assistant" {
  default     = false
  type        = bool
  description = "Install Watson™ Assistant module. Only for Cloud Pak for Data v3.0"
}
variable "install_watson_assistant_for_voice_interaction" {
  default     = false
  type        = bool
  description = "Install Watson Assistant for Voice Interaction module. Only for Cloud Pak for Data v3.0"
}
variable "install_watson_discovery" {
  default     = false
  type        = bool
  description = "Install Watson Discovery module. Only for Cloud Pak for Data v3.0"
}
variable "install_watson_knowledge_studio" {
  default     = false
  type        = bool
  description = "Install Watson Knowledge Studio module. Only for Cloud Pak for Data v3.0"
}
variable "install_watson_language_translator" {
  default     = false
  type        = bool
  description = "Install Watson Language Translator module. Only for Cloud Pak for Data v3.0"
}
variable "install_watson_speech_text" {
  default     = false
  type        = bool
  description = "Install Watson Speech to Text or Watson Text to Speech module. Only for Cloud Pak for Data v3.0"
}
variable "install_edge_analytics" {
  default     = false
  type        = bool
  description = "Install Edge Analytics module. Only for Cloud Pak for Data v3.0"
}

// Modules available to install on CP4D v3.5

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
  namespace                = "cloudpak4data"
  entitled_registry        = "cp.icr.io"
  entitled_registry_user   = "cp"
  docker_registry          = "cp.icr.io/cp/cpd"
  docker_username          = "cp" // "ekey"
  entitled_registry_key    = chomp(var.entitled_registry_key)
  openshift_version_regex  = regex("(\\d+).(\\d+)(.\\d+)*(_openshift)*", var.openshift_version)
  openshift_version_number = local.openshift_version_regex[3] == "_openshift" ? tonumber("${local.openshift_version_regex[0]}.${local.openshift_version_regex[1]}") : 0
  // For Staging, use:
  // docker_registry          = "cp.stg.icr.io/cp/cpd"
}
