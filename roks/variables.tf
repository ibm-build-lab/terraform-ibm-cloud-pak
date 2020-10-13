// ROKS Module Variables

variable "enable" {
  type        = bool
  default     = true
  description = "if false the ROKS cluster will not be created. This variable won't be required for Terraform 0.13+"
}

variable "on_vpc" {
  type        = bool
  default     = true
  description = "if true the ROKS cluster will be created in IBM Cloud VPC, otherwise will be Classic"
}

variable "project_name" {
  description = "The project name is used to name the cluster with the environment name"
}
variable "owner" {
  description = "Use your user name or team name. The owner is used to label the cluster and other resources"
}

variable "environment" {
  default     = "dev"
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

// Kubernetes Config & Config File(s)

variable "download_config" {
  type        = bool
  default     = false
  description = "if true download the kubernetes configuration files and certificates to the directory that you specified in config_dir"
}

variable "config_dir" {
  default     = "."
  description = "directory on your local machine where you want to download the Kubernetes config files and certificates"
}

variable "config_admin" {
  type        = bool
  default     = false
  description = "if set to true, the Kubernetes configuration for cluster administrators is downloaded"
}

variable "config_network" {
  type        = bool
  default     = false
  description = "if set to true, the Calico configuration file, TLS certificates, and permission files that are required to run calicoctl commands in your cluster are downloaded in addition to the configuration files for the administrator"
}

// ROKS Module : On IBM Cloud Classic

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

// ROKS Module : On IBM Cloud VPC Gen 2 (Only for Terraform >= 0.12)

variable "vpc_zone_names" {
  type        = list(string)
  default     = ["us-south-1"]
  description = "Array with the subzones in the region, to create the workers groups. List all the zones with: 'ibmcloud ks zone ls --provider vpc-gen2'. Example: ['us-south-1', 'us-south-2', 'us-south-3']"
}

variable "flavors" {
  type        = list(string)
  default     = ["mx2.4x32"]
  description = "Array with the flavors or machine types of each the workers group. List all flavors for each zone with: 'ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2'. Example: ['mx2.4x32', 'mx2.8x64', 'cx2.4x8']"
}

variable "workers_count" {
  type        = list(number)
  default     = [2]
  description = "Array with the amount of workers on each workers group. Example: [1, 3, 5]"
}

// ROKS Module : Local Variables

locals {
  max_size        = length(var.vpc_zone_names)
  cluster_name_id = var.on_vpc ? join("", ibm_container_vpc_cluster.cluster.*.id) : join("", ibm_container_cluster.cluster.*.id)
  roks_version    = format("%s_openshift", split("_", var.roks_version)[0])
}

