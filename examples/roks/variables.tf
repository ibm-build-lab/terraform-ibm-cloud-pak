variable "on_vpc" {
  default = false
  type        = bool
  description = "To determine infrastructure. Options are `true` = installs on VPC, `false`  installs on classic"
}

variable "entitlement" {
  default = "cloud_pak"
  description = "OCP entitlement"
}

variable "region" {
  description = "List all available regions with: ibmcloud regions"
}

// Cluster configuration input variables and default values:

variable "cluster_id" {
  default     = ""
  description = "An existing cluster ID or name to install Cloud Paks on. If left blank, a new ROKS cluster will be provisioned."
}

variable "config_dir" {
  default     = "./.kube/config"
  description = "directory to store the kubeconfig file, set the value to empty string to not download the config"
}

variable "project_name" {
  default     = "roks-tfmod"
  description = "The project name is used to name the cluster with the environment name"
}
variable "owner" {
  default     = "tester"
  description = "Use your user name or team name. The owner is used to label the cluster and other resources"
}
variable "environment" {
  default     = "test"
  description = "The environment name is used to name the cluster with the project name"
}
variable "resource_group" {
  default     = "Default"
  description = "List all available resource groups with: ibmcloud resource groups"
}
variable "roks_version" {
  default     = "4.6"
  description = "List available versions: ibmcloud ks versions"
}
variable "force_delete_storage" {
  type        = bool
  default     = false
  description = "If set to true, force the removal of persistent storage associated with the cluster during cluster deletion. Default value is false"
}

// OpenShift cluster specific input parameters and default values:

variable "vpc_zone_names" {
  type    = list(string)
  default = ["us-south-1"]
}
variable "flavors" {
  type    = list(string)
  default = ["b2c.16x64"]
}
variable "workers_count" {
  type    = list(number)
  default = [4]
}

variable "datacenter" {
  description = "List all available datacenters/zones with: ibmcloud ks zone ls --provider classic"
  default = "dal12"
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

