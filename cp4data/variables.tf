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

variable "cluster_endpoint" {
  default     = "not-required"
  description = "URL to access the OpenShift cluster"
}

variable "entitled_registry_key" {
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  description = "Docker email address"
}

variable "storage_class_name" {
  default     = "ibmc-file-gold-gid"
  description = "Storage Class name to use"
}

// variable "cp4data_config_file" {
//   default = "./repo.yaml"
//   description = "location to "
// }


// Modules available install

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

locals {
  data_namespace           = "cloudpak4data"
  entitled_registry        = "cp.icr.io"
  entitled_registry_user   = "cp"
  entitled_registry_key    = chomp(var.entitled_registry_key)
  openshift_version_regex  = regex("(\\d+).(\\d+)(.\\d+)*(_openshift)*", var.openshift_version)
  openshift_version_number = local.openshift_version_regex[3] == "_openshift" ? tonumber("${local.openshift_version_regex[0]}.${local.openshift_version_regex[1]}") : 0
}
