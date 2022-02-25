variable "region" {
  default     = "us-south"
  description = "Region where the cluster is created."
}

variable "resource_group" {
  default     = "cloud-pak-sandbox"
  description = "Resource group name where the cluster will be hosted."
}

variable "cluster_config_path" {
  description = "Path to the cluster configuration file to access your cluster"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Email address of the user owner of the Entitled Registry Key"
}

variable "entitled_registry_key" {
  type        = string
  description = "Do you have a Cloud Pak for Business Automation Entitlement Registry key? If not, Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

# --------- DB2 SETTINGS ----------
variable "enable_db2" {
  default     = true
  description = "If set to true, it will install DB2 on the given cluster"
}

 variable "db2_project_name" {
   default     = "ibm-db2"
   description = "The namespace or project for Db2"
 }

variable "db2_admin_user_password" {
  description = "Db2 admin user password defined in LDAP"
}

variable "db2_admin_username" {
  default     = "db2inst1"
  description = "Db2 admin username defined in LDAP"
}


variable "operatorVersion" {
  default     = "db2u-operator.v1.1.11"
  description = "Operator version"
}

variable "db2_standard_license_key" {
  default     = ""
  description = "Leave blank for standard licence. Specify the db2 license key for Advanced."
}

variable "operatorChannel" {
  default     = "v1.1"
  description = "The Operator Channel performs rollout update when new release is available."
}

variable "db2_instance_version" {
  default     = "11.5.6.0"
  description = "DB2 version to be installed"
}

variable "db2_cpu" {
  default     = "4"
  description = "CPU setting for the pod requests and limits"
}

variable "db2_memory" {
  default     = "16Gi"
  description = "Memory setting for the pod requests and limits"
}

variable "db2_storage_size" {
  default     = "150Gi"
  description = "Storage size for the db2 databases"
}

variable "db2_storage_class" {
  default     = "ibmc-file-gold-gid"
  description = "Name for the Storage Class"
}

locals {
  docker_server   = "cp.icr.io"
  docker_username = "cp"
}
