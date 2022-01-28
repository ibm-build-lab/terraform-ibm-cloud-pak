variable "cluster_id" {
  default     = ""
  description = "Enter your cluster id or name to install the Cloud Pak. Leave blank to provision a new Openshift cluster."
}

variable "cluster_config_path" {
  default     = ".kube/config"
  type        = string
  description = "Path to the cluster configuration file to access your cluster"
}

variable "resource_group" {
  default     = "cloud-pak-sandbox-ibm"
  description = "Resource group name where the cluster will be hosted."
}
variable "entitled_registry_user_email" {
  type        = string
  description = "Email address of the user owner of the Entitled Registry Key"
}

variable "entitlement_key" {
  type        = string
  description = "Do you have a Cloud Pak for Business Automation Entitlement Registry key? If not, Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

# --------- DB2 SETTINGS ----------
variable "enable" {
  default = true
  description = "If set to true, it will install DB2 on the given cluster"
}

 variable "db2_project_name" {
   default = "ibm-db2"
   description = "The namespace/project for Db2"
 }
variable "db2_admin_user_password" {
  description = "Db2 admin user password defined in LDAP"
}

variable "db2_admin_username" {
  default = "db2inst1"
  description = "Db2 admin username defined in LDAP"
}

//variable "db2_host_name" {
//  description = "Host name of Db2 instance"
//}
//
//variable "db2_host_ip" {
//  description = "IP address for the Db2"
//}
//
//variable "db2_port_number" {
//  description = "Port for Db2 instance"
//}
//
variable "db2_standard_license_key" {
  description = "The standard license key for the Db2 database product"
}

locals {
  docker_server                     = "cp.icr.io"
  docker_username                   = "cp"
}
