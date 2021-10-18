
variable "on_vpc" {
  type        = bool
  default     = false
  description = "if true the ROKS cluster will be created in IBM Cloud VPC, otherwise will be Classic"
  // default     = "true"
}

variable "cluster_id" {
  description = "ROKS cluster id. Use the ROKS terraform module or other way to create it"
}

variable "region" {
  description = "Region of the cluster"
}

variable "resource_group" {
  description = "Resource group that the cluster is created in"
}

variable "ibmcloud_api_key" {
  description = "IBMCloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "entitled_registry_user_email" {
  description = "Email address of the user owner of the Entitled Registry Key"
}

variable "entitled_registry_key" {
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

// ROKS Module : Local Variables and constants
locals {
  entitled_registry_key_file = "../../entitlement.key"
  config_dir                 = "./.kube/config"
}
