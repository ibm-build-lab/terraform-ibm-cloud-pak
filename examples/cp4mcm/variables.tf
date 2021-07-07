// IBM Cloud API Key
variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key. Go here for information on how to create: https://cloud.ibm.com/iam/apikeys"
}

// Cluster Variables
// if set to false, cluster is on Classic Infrastructure
variable "cluster_id" {
  default     = ""
  description = "**Optional**: if you have an existing cluster to install the Cloud Pak, use the cluster ID or name. If left blank, a new Openshift cluster will be provisioned"
}

variable "on_vpc" {
  type        = bool
  default     = false
  description = "Ignored if `cluster_id` is specified. Cluster type to be created, 'true' = VPC, 'false' = Classic"
}

// Required if cluster id is not specified
variable "region" {
  default     = "us-south"
  description = "Ignored if `cluster_id` is specified. Region to provision the Openshift cluster. List all available regions with: ibmcloud regions"
}

// Required if cluster id is not specified
variable "resource_group" {
  default     = "Default"
  description = "Ignored if `cluster_id` is specified. Resource Group to host the cluster. List all available resource groups with: `ibmcloud resource groups`"
}
// Required if cluster id is not specified
variable "project_name" {
  description = "Ignored if `cluster_id` is  specified. The project_name is combined with `environment` to name the cluster. The cluster name will be '{project_name}-{environment}-cluster' and all the resources will be tagged with 'project:{project_name}'"
}
// Required if cluster id is not specified
variable "environment" {
  default     = "dev"
  description = "Ignored if `cluster_id` is specified. The environment is combined with `project_name` to name the cluster. The cluster name will be '{project_name}-{environment}-cluster' and all the resources will be tagged with 'env:{environment}'"
}
// Required if cluster id is not specified
variable "owner" {
  description = "Ignored if `cluster_id` is specified. Use your user name or team name. The owner is used to label the cluster and other resources with the tag 'owner:{owner}'"
}

// Required if cluster id is not specified. Flavor will depend on whether classic or vpc
variable "flavors" {
  type        = list(string)
  default     = ["b3c.16x64"]
  description = "Ignored if `cluster_id` is specified. Array with the flavors or machine types of each the workers group. Classic only takes the first flavor of the list. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider <classic | vpc-gen2>`. Classic: `[\"b3c.16x64\"]`, VPC: `[\"bx2.16x64\"]`"
}

// Only required if cluster id is not specified and 'on_vpc=true'
variable "vpc_zone_names" {
  type        = list(string)
  default     = ["us-south-1"]
  description = "**VPC Only**. Ignored if `cluster_id` is specified. Zones in the IBM Cloud VPC region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider vpc-gen2`. Only required if cluster id not specified and `on_vpc=true`."
}

// Classic Only. Required if cluster id is not specified and 'on_vpc=false'
variable "datacenter" {
  default     = ""
  description = "**Classic Only**: Ignored if `cluster_id` is specified.  Datacenter or Zone in the region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`. Only required if cluster id not specified and `on_vpc=false`."
}

// Classic Only: VLAN's numbers on the datacenter
// Required if cluster id is not specified and 'on_vpc=false'
variable "private_vlan_number" {
  default     = ""
  description = "**Classic Only**: Ignored if `cluster_id` is specified. Private VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone <datacenter>`, make sure the the VLAN type is private and the router begins with bc. Use the ID or Number."
}
variable "public_vlan_number" {
  default     = ""
  description = "**Classic Only**: Ignored if `cluster_id` is specified. Public VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone <datacenter>`, make sure the the VLAN type is public and the router begins with fc. Use the ID or Number."
}

// MCM Module Variables
variable "entitled_registry_key" {
  default     = ""
  description = "Required: Cloud Pak Entitlement Key. Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary, copy and paste the key to this variable"
}
variable "entitled_registry_user_email" {
  description = "Required: Email address of the user owner of the Entitled Registry Key"
}
variable "install_infr_mgt_module" {
  default     = false
  type        = bool
  description = "Set to 'true' to install the Infrastructure Management module"
}
variable "install_monitoring_module" {
  default     = false
  type        = bool
  description = "Set to 'true' to install the Monitoring module"
}
variable "install_security_svcs_module" {
  default     = false
  type        = bool
  description = "Set to 'true' to install the Security Services module"
}
variable "install_operations_module" {
  default     = false
  type        = bool
  description = "Set to 'true' to install the Operations module"
}
variable "install_tech_prev_module" {
  default     = false
  type        = bool
  description = "Set to 'true' to install the Tech Preview module"
}

// Local Variables and constants
locals {
  // ROKS variables
  workers_count              = [5]
  roks_version               = "4.6"
  kubeconfig_dir             = "./.kube/config"
  // MCM variables
  entitled_registry_key_file = "./entitlement.key"
}
