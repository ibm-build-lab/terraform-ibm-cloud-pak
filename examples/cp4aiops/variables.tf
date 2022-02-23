variable "cluster_id" {
  description = "Enter the existing cluster's ID to install the Cloud Pak for AIOps on."
}

variable "ibmcloud_api_key" {
  description = "IBMCloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "region" {
  description = "Region that cluster resides in"
}

variable "resource_group" {
  default     = "cloud-pak-sandbox-ibm"
  description = "Resource group that cluster resides in"
}

variable "on_vpc" {
  default     = false
  type        = bool
  description = "If set to true, lets the module know cluster is using VPC Gen2"
}

variable "entitled_registry_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Docker email address"
}

variable "cp4aiops_namespace" {
  default = "cp4aiops"
  description = "Namespace for Cloud Pak for AIOps"
}

variable "cluster_config_path" {
  description = "Path to the Kubernetes configuration file to access your cluster"
  default     = "./.kube/config"
}
