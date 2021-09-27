
variable "ibmcloud_api_key" {
  description = "IBM Cloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "cluster_name_or_id" {
  default     = ""
  description = "Enter your cluster id or name to install the Cloud Pak. Leave blank to provision a new Openshift cluster."
}

variable "region" {
  default     = "us-south"
  description = "Region where the cluster is hosted."
}

variable "resource_group" {
  default     = "partner-sandbox"
  description = "Resource group name where the cluster is hosted."
}

variable "entitlement_key" {
  type        = string
  description = "Do you have a Cloud Pak for Business Automation Entitlement Registry key? If not, Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user" {
  type = string
  description = "Email address of the user owner of the Entitled Registry Key"
}

# Use the id and password that you specified when setting up LDAP
variable "ldap_admin" {
  default = "cn=root"
  description = "LDAP Admin user name"
}

variable "ldap_password" {
  default = "Passw0rd"
  description = "LDAP Admin password"
}

variable "ldap_host_ip" {
  default = ""
  description = "LDAP server IP address"
}


# -------- DB2 Variables ---------
variable "db2_admin" {
  default = "cpadmin"
  description = "Admin user name defined in LDAP"
}

variable "db2_user" {
  default = "db2inst1"
  description = "User name defined in LDAP"
}

variable "db2_password" {
  default = "passw0rd"
  description = "Password defined in LDAP"
}

variable "db2_host_name" {
  default     = ""
  description = "Host for DB2 instance"
}

variable "db2_host_port" {
  default     = ""
  description = "Port for DB2 instance"
}

locals {
  kube_config_path = "./.kube/config"
  namespace        = "cp4ba"
}
