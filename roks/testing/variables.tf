variable "infra" {
  default = "classic"
  // default = "vpc"
  description = "infrastructure to install the cluster, the available options are: 'classic' and 'vpc'"
}

// Cluster configuration input variables and default values:

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
  default     = "default"
  description = "List all available resource groups with: ibmcloud resource groups"
}
variable "roks_version" {
  default     = "4.4_openshift"
  description = "List available versions: ibmcloud ks versions"
}

// IBM Classic input parameters and default values:

variable "datacenter" {
  default     = "dal10"
  description = "List all available datacenters/zones with: ibmcloud ks zone ls --provider classic"
}
variable "size" {
  default = 1
}
variable "flavor" {
  default     = "b3c.4x16"
  description = "List all available flavors in the zone: ibmcloud ks flavors --zone dal10"
}
variable "private_vlan_number" {
  default     = "2832804"
  description = "List available VLANs in the zone: ibmcloud ks vlan ls --zone dal10"
}
variable "public_vlan_number" {
  default     = "2832802"
  description = "List available VLANs in the zone: ibmcloud ks vlan ls --zone dal10"
}

// IBM VPC input parameters and default values are in str_to_list.tf
