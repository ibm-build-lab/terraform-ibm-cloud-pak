variable "ibmcloud_api_key" {
  description = "Enter your IBM API Cloud access key. Visit this link for more information: https://cloud.ibm.com/docs/account?topic=account-userapikey&interface=ui "
}

variable "cluster_id" {
  default     = ""
  description = "Set your cluster ID to install the Cloud Pak for Business Automation. Leave blank to provision a new OpenShift cluster."
}

variable "ingress_subdomain" {
  default     = ""
  description = "Run the command `ibmcloud ks cluster get -c <cluster_name_or_id>` to get the Ingress Subdomain value"
}

variable "resource_group" {
  default     = "Default"
  description = "Resource group name where the cluster is hosted."
}

variable "region" {
    description = "Region where the cluster is hosted."
}

variable "cluster_config_path" {
  default     = "./.kube/config"
  description = "directory to store the kubeconfig file"
}

variable "entitled_registry_key" {
  type        = string
  description = "Do you have a Cloud Pak for Business Automation Entitlement Registry key? If not, Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Email address of the user owner of the Entitled Registry Key"
}

variable "cp4ba_project_name" {
  default     = "cp4ba"
  description = "Namespace or project for cp4ba"
}

variable "enable_cp4ba" {
  description = "If set to true, it will install CP4BA on the given cluster"
  type = bool
  default = true
}

# -------- LDAP Variables ---------
# Use the id and password that you specified when setting up LDAP
variable "ldap_admin" {
  default     = "cn=root"
  description = "LDAP Admin user name"
}

variable "ldap_password" {
  default     = "Passw0rd"
  description = "LDAP Admin password"
}

variable "ldap_host_ip" {
  default     = ""
  description = "LDAP server IP address"
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

variable "db2_admin" {
  default     = "cpadmin"
  description = "Admin user name defined in LDAP"
}

variable "db2_user" {
  default     = "db2inst1"
  description = "User name defined in LDAP"
}

variable "db2_admin_user_password" {
  description = "Db2 admin user password defined in LDAP"
}

variable "db2_host_address" {
  description = "Host name for DB2 instance. Ignore if there is not an existing Db2."
  default     = ""
}

variable "db2_ports" {
  description = "Port number for DB2 instance. Ignore if there is not an existing Db2."
  default = ""
}

locals {
  cluster_config_path = "./.kube/config"
  namespace           = "cp4ba"
  docker_server       = "cp.icr.io"
  docker_username     = "cp"
}
