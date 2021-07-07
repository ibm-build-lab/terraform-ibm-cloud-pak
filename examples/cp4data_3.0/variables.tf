variable "region" {
  default     = "us-south"
  description = "Region to provision the Openshift cluster. List all available regions with: ibmcloud regions"
}
variable "project_name" {
  description = "The project_name is combined with environment to name the cluster. The cluster name will be '{project_name}-{environment}-cluster' and all the resources will be tagged with 'project:{project_name}'"
}
variable "owner" {
  description = "Use your user name or team name. The owner is used to label the cluster and other resources with the tag 'owner:{owner}'"
}
variable "environment" {
  default     = "dev"
  description = "The environment is combined with project_name to name the cluster. The cluster name will be '{project_name}-{environment}-cluster' and all the resources will be tagged with 'env:{environment}'"
}
variable "resource_group" {
  default     = "default"
  description = "Resource Group in your account to host the cluster. List all available resource groups with: ibmcloud resource groups"
}
variable "cluster_id" {
  default     = ""
  description = "If you have an existing cluster to install the Cloud Pak, use the cluster ID or name. If left blank, a new Openshift cluster will be provisioned"
}
variable "datacenter" {
  default     = "dal10"
  description = "Datacenter or Zone in the IBM Cloud Classic region to provision the cluster. List all available zones with: ibmcloud ks zone ls --provider classic"
}
// Cluster Variables
// if set to false, cluster is on Classic Infrastructure
variable "on_vpc" {
  type        = bool
  default     = false
  description = "Required: Cluster type to be installed on, 'true' = VPC, 'false' = Classic"
}
// Only required if cluster id is not specified and 'on_vpc=true'
variable "vpc_zone_names" {
  type        = list(string)
  default     = ["us-south-1"]
  description = "VPC Only: Only required if cluster_id is not specified. Zones in the IBM Cloud VPC region to provision the cluster. List all available zones with: 'ibmcloud ks zone ls --provider vpc-gen2'. Only required if cluster id not specified and on_vpc=true."
}
// VLAN's numbers variables on the datacenter, they are here until the
// permissions issues is fixed on Humio account
variable "private_vlan_number" {
  default     = ""
  description = "Private VLAN assigned to your zone. List available VLANs in the zone: ibmcloud ks vlan ls --zone, make sure the the VLAN type is private and the router begins with bc. Use the ID or Number"
}
variable "public_vlan_number" {
  default     = ""
  description = "Public VLAN assigned to your zone. List available VLANs in the zone: ibmcloud ks vlan ls --zone, make sure the the VLAN type is public and the router begins with fc. Use the ID or Number"
}

// CP4DATA Module Variables

// TODO: Include this variable in a future release to install/uninstall cp4data
// variable "cp4data_installer_comand" {
//   default     = "install"
//   description = "Command to execute by the cp4data installer, the most common are: install, uninstall, check, upgrade"
// }

variable "entitled_registry_key" {
  default     = ""
  description = "Cloud Pak Entitlement Key. Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary, copy and paste the key to this variable"
}
variable "entitled_registry_user_email" {
  description = "Email address of the user owner of the Entitled Registry Key"
}

// Modules available to install

variable "install_guardium_external_stap" {
  default     = false
  type        = bool
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
  type        = bool
  description = "Install Watson™ Assistant module"
}
variable "install_watson_assistant_for_voice_interaction" {
  default     = false
  type        = bool
  description = "Install Watson Assistant for Voice Interaction module"
}
variable "install_watson_discovery" {
  default     = false
  type        = bool
  description = "Install Watson Discovery module"
}
variable "install_watson_knowledge_studio" {
  default     = false
  type        = bool
  description = "Install Watson Knowledge Studio module"
}
variable "install_watson_language_translator" {
  default     = false
  type        = bool
  description = "Install Watson Language Translator module"
}
variable "install_watson_speech_text" {
  default     = false
  type        = bool
  description = "Install Watson Speech to Text or Watson Text to Speech module"
}
variable "install_edge_analytics" {
  default     = false
  type        = bool
  description = "Install Edge Analytics module"
}

// ROKS Module : Local Variables and constansts

locals {
  infra                      = "classic"
  flavors                    = ["b3c.16x64"]
  workers_count              = [4]
  roks_version               = "4.5"
  kubeconfig_dir             = "./.kube/config"
  entitled_registry_key_file = "./entitlement.key"
}
