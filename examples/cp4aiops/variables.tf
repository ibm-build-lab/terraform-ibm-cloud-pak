variable "cluster_name_or_id" {
  description = "Id of cluster for AIOps to be installed on"
}

variable "ibmcloud_api_key" {
  description = "IBMCloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "region" {
  description = "Region that cluster resides in"
}

variable "resource_group_name" {
  default     = "cloud-pak-sandbox-ibm"
  description = "Resource group that cluster resides in"
}

variable "on_vpc" {
  default     = false
  type        = bool
  description = "If set to true, lets the module know cluster is using VPC Gen2"
}

variable "entitlement_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user" {
  type        = string
  description = "Docker email address"
}

locals {
  cluster_config_path = "./.kube/config"
}

