variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for Multi Cloud Management on the given cluster"
}

variable "cluster_config_path" {
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "cluster_name_id" {
  default     = ""
  description = "Name or id of the cluster"
}

variable "on_vpc" {
  default     = false
  description = "Cluster type. VPC: `on_vpc=true`, Classic: `on_vpc=false`"
}

variable "region" {
  default     = "us-south"
  description = "Region the Openshift cluster is provisioned on. List all available regions with: `ibmcloud regions`"
}

variable "zone" {
  default     = "dal10"
  description = "Zone in the region the Openshift cluster is provisioned on. List all available zones with: `ibmcloud ks zone ls --provider <classic | vpc-gen2>`"
}

variable "ibmcloud_api_key" {
  description = "IBMCloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "entitled_registry_key" {
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  description = "Docker email address"
}

variable "namespace" {
  default     = "cp4mcm"
  description = "Namespace to install the Cloud Pak in"
}

variable "install_infr_mgt_module" {
  default     = false
  description = "Install Infrastructure Management module"
}

variable "install_monitoring_module" {
  default     = false
  description = "Install Monitoring module"
}

variable "install_security_svcs_module" {
  default     = false
  description = "Install Security Services module"
}

variable "install_operations_module" {
  default     = false
  description = "Install Operations module"
}

variable "install_tech_prev_module" {
  default     = false
  description = "Install Tech Preview module"
}

locals {
  entitled_registry      = "cp.icr.io"
  entitled_registry_user = "cp"
  entitled_registry_key  = chomp(var.entitled_registry_key)
  ibmcloud_api_key       = chomp(var.ibmcloud_api_key)
}
