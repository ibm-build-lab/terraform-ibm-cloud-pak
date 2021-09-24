variable "enable" {
  default = true
  description = "If set to true installs Cloud-Pak for Integration on the given cluster"
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "cluster_name_or_id" {
  default     = ""
  description = "Enter your cluster id or name to install the Cloud Pak. Leave blank to provision a new Openshift cluster."
}

variable "kube_config_path" {
  default     = ".kube/config"
  type        = string
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "resource_group" {
  default     = "cloud-pak-sandbox-ibm"
  description = "Resource group name where the cluster will be hosted."
}

variable "entitlement_key" {
  type        = string
  description = "Do you have a Cloud Pak for Business Automation Entitlement Registry key? If not, Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  type = string
  description = "Email address of the user owner of the Entitled Registry Key"
}

# use the id and password that you specified when setting up LDAP
variable "ldap_admin_user" {}
variable "ldap_admin_password" {}
variable "ldap_server_ip" {}

variable "cp4ba_project_name" {
  default = "cp4ba"
  description = "Project name or namespace where Cloud Pak for Business Automation will be installed."
}

# -------- STORAGE-CLASSES ---------

variable "sc_slow_file_storage_classname" {
  default = "ibmc-file-bronze-gid"
  description = "Slow Storage Class"
}

variable "sc_medium_file_storage_classname" {
  default = "ibmc-file-silver-gid"
  description = "Medium Storage Class"
}

variable "sc_fast_file_storage_classname" {
  default = "ibmc-file-gold-gid"
  description = "Fast Storage-Class"
}

# -------- DB2 Variables ---------
variable "db2_admin_user_password" {
  default = "passw0rd"
}

variable "db2_admin_username" {
  default = "db2inst1"
}

variable "db2_host_ip" {}

variable "db2_port_number" {}

locals {
  //  cp4ba_namespace              = "cp4ba"
  entitled_registry_key_secret_name  = "ibm-entitlement-key"
  docker_server                = "cp.icr.io"
  docker_username              = "cp"
  docker_email                 = var.entitled_registry_user_email
  enable_cluster               = var.cluster_name_or_id == "" || var.cluster_name_or_id == null
  use_entitlement              = "yes"
  ibmcloud_api_key             = chomp(var.ibmcloud_api_key)
}




