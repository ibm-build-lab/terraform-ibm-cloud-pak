variable "infra" {
  default = "classic"
  // default = "vpc"
  description = "infrastructure to install the cluster, the available options are: 'classic' and 'vpc'"
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
  default     = "roks-tfmod-01"
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
  default     = "default"
  description = "List all available resource groups with: ibmcloud resource groups"
}
variable "roks_version" {
  default     = "4.4"
  description = "List available versions: ibmcloud ks versions"
}

// IBM Classic input parameters and default values:

variable "datacenter" {
  description = "List all available datacenters/zones with: ibmcloud ks zone ls --provider classic"
}

// IBM VPC input parameters and default values are in str_to_list.tf

// Output the resource group used as input, it may be needed

output "resource_group" {
  value = var.resource_group
}
