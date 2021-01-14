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


// Modules available to install

variable "install_guardium_external_stap" {
  default     = false
  description = "Install Guardium® External S-TAP® module"
}
variable "docker_id" {
  default     = ""
  description = "Docker ID required to install Guardium® External S-TAP® module"
}
variable "docker_access_token" {
  default     = ""
  description = "Docker access token required to install Guardium® External S-TAP® module"
}
variable "install_watson_assistant" {
  default     = false
  description = "Install Watson™ Assistant module"
}
variable "install_watson_assistant_for_voice_interaction" {
  default     = false
  description = "Install Watson Assistant for Voice Interaction module"
}
variable "install_watson_discovery" {
  default     = false
  description = "Install Watson Discovery module"
}
variable "install_watson_knowledge_studio" {
  default     = false
  description = "Install Watson Knowledge Studio module"
}
variable "install_watson_language_translator" {
  default     = false
  description = "Install Watson Language Translator module"
}
variable "install_watson_speech_text" {
  default     = false
  description = "Install Watson Speech to Text or Watson Text to Speech module"
}
variable "install_edge_analytics" {
  default     = false
  description = "Install Edge Analytics module"
}

// TODO: Identify what are these modules name as well as the default value
variable "install_WKC" {
  default     = false
  description = "Install WKC module"
}
variable "install_WSL" {
  default     = false
  description = "Install WSL module"
}
variable "install_WML" {
  default     = false
  description = "Install WML module"
}
variable "install_AIOPENSCALE" {
  default     = false
  description = "Install AIOPENSCALE module"
}
variable "install_DV" {
  default     = false
  description = "Install DV module"
}
variable "install_STREAMS" {
  default     = false
  description = "Install STREAMS module"
}
variable "install_CDE" {
  default     = false
  description = "Install CDE module"
}
variable "install_SPARK" {
  default     = false
  description = "Install SPARK module"
}
variable "install_DB2WH" {
  default     = false
  description = "Install DB2WH module"
}
variable "install_DATAGATE" {
  default     = false
  description = "Install DATAGATE module"
}
variable "install_RSTUDIO" {
  default     = false
  description = "Install RSTUDIO module"
}
variable "install_DMC" {
  default     = false
  description = "Install DMC module"
}

locals {
  namespace                = "cloudpak4data"
  entitled_registry        = "cp.icr.io"
  entitled_registry_user   = "cp"
  docker_registry          = join("/", [local.entitled_registry, local.entitled_registry_user, "cpd"])
  docker_username          = "ekey"
  entitled_registry_key    = chomp(var.entitled_registry_key)
  openshift_version_regex  = regex("(\\d+).(\\d+)(.\\d+)*(_openshift)*", var.openshift_version)
  openshift_version_number = local.openshift_version_regex[3] == "_openshift" ? tonumber("${local.openshift_version_regex[0]}.${local.openshift_version_regex[1]}") : 0
}
