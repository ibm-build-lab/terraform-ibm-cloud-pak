variable "ibmcloud_api_key" {
  description = "IBMCloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "region" {
  description = "Region where the cluster is created."
}

variable "resource_group" {
  description = "Resource group name where the cluster will be hosted."
}

variable "cluster_id" {
  description = "Enter your cluster id or name to install the Cloud Pak."
}

variable "cluster_config_path" {
  description = "Directory to store the kubeconfig file, set the value to empty string to not download the config. If running on Schematics, use `/tmp/.schematics/.kube/config`"
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
   description = "The namespace/project for Db2"
 }

variable "db2_admin_user_password" {
  description = "Db2 admin user password defined in LDAP"
}

variable "db2_name" {
  default    = "MYDB01"
  description = "A name you would like to attribute to your Database. i.e: MYDB01.  Name must be less than or equal to 8 bytes and contain no special characters"
}

variable "db2_admin_username" {
  default     = "db2inst1"
  description = "Db2 default admin username."
}

variable "db2_standard_license_key" {
  default     = ""
  description = "The standard license key for the Db2 database product. Note: the license key is required only for Advanced DB2 installation. Click here to download it: (https://w3-03.ibm.com/software/xl/download/ticket.wss) or [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/)"
}

variable "operatorVersion" {
  default     = "db2u-operator.v2.0.0"
  description = "Operator version"
}

variable "operatorChannel" {
  default     = "v2.0"
  description = "The Operator Channel performs rollout update when new release is available."
}

variable "db2_instance_version" {
  default     = "11.5.7.0-cn3"
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
  default     = "100Gi"
  description = "Storage size for the db2 databases"
}

variable "db2_rwx_storage_class" {
  default     = "ibmc-file-gold-gid"
  description = "Name for the RWX File Storage Class"
}

variable "db2_rwo_storage_class" {
  default     = "ibmc-block-gold"
  description = "Name for the RWO Block Storage Class. Use `ibmc-block-gold` for classic, `ibmc-vpc-block-10iops-tier` for vpc"
}

locals {
  docker_server   = "cp.icr.io"
  docker_username = "cp"
}
