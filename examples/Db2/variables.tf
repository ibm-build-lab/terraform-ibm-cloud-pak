variable "cluster_name_or_id" {
  default     = ""
  description = "Enter your cluster id or name to install the Cloud Pak. Leave blank to provision a new Openshift cluster."
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

variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for Business Automation on the given cluster"
}

variable "cluster_config_path" {
  default     = "./.kube/config"
  description = "Directory to store the kubeconfig file, set the value to empty string to not download the config. If running on Schematics, use `/tmp/.schematics/.kube/config`"
}

locals {
  db2_admin_user_password  = ""
  db2_standard_license_key = ""
  db2_admin_user_name      = "db2inst1"
  db2_project_name         = "ibm-db2"
}

locals {
  entitled_registry_key_secret_name = "ibm-entitlement-key"
  docker_secret_name                = "docker-registry"
  docker_server                     = "cp.icr.io"
  docker_username                   = "cp"
  docker_password                   = chomp(var.entitlement_key)
  docker_email                      = var.entitled_registry_user_email
  project_name                      = "cp4ba"
}

