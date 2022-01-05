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

locals {
  # CP4BA Database Name information
  //  db2_ums_db_name   = "UMSDB"
  //  db2_icn_db_name   = "ICNDB"
  //  db2_devos_1_name  = "DEVOS1"
  //  db2_aeos_name     = "AEOS"
  //  db2_baw_docs_name = "BAWDOCS"
  //  db2_baw_tos_name  = "BAWTOS"
  //  db2_baw_dos_name  = "BAWDOS"
  //  db2_baw_Db_name   = "BAWDB"
  //  db2_app_db_name   = "APPDB"
  //  db2_ae_db_name    = "AEDB"
  //  db2_bas_db_name   = "BASDB"
  //  db2_gcd_db_name   = "GCDDB"
  db2_admin_user_password  = "passw0rd"
  db2_standard_license_key = "W0xpY2Vuc2VDZXJ0aWZpY2F0ZV0KQ2hlY2tTdW09Q0FBODlCOTA0QzU3RTY2OTU1RjJDQTY4MzlCRTZCOTMKVGltZVN0YW1wPTE1NjU3MjM5MDIKUGFzc3dvcmRWZXJzaW9uPTQKVmVuZG9yTmFtZT1JQk0gVG9yb250byBMYWIKVmVuZG9yUGFzc3dvcmQ9N3Y4cDRmcTJkdGZwYwpWZW5kb3JJRD01ZmJlZTBlZTZmZWIuMDIuMDkuMTUuMGYuNDguMDAuMDAuMDAKUHJvZHVjdE5hbWU9REIyIFN0YW5kYXJkIEVkaXRpb24KUHJvZHVjdElEPTE0MDUKUHJvZHVjdFZlcnNpb249MTEuNQpQcm9kdWN0UGFzc3dvcmQ9MzR2cnc1MmQyYmQyNGd0NWFmNHU4Y2M0ClByb2R1Y3RBbm5vdGF0aW9uPTEyNyAxNDMgMjU1IDI1NSA5NCAyNTUgMSAwIDAgMC0yNzsjMCAxMjggMTYgMCAwCkFkZGl0aW9uYWxMaWNlbnNlRGF0YT0KTGljZW5zZVN0eWxlPW5vZGVsb2NrZWQKTGljZW5zZVN0YXJ0RGF0ZT0wOC8xMy8yMDE5CkxpY2Vuc2VEdXJhdGlvbj02NzE2CkxpY2Vuc2VFbmREYXRlPTEyLzMxLzIwMzcKTGljZW5zZUNvdW50PTEKTXVsdGlVc2VSdWxlcz0KUmVnaXN0cmF0aW9uTGV2ZWw9MwpUcnlBbmRCdXk9Tm8KU29mdFN0b3A9Tm8KQnVuZGxlPU5vCkN1c3RvbUF0dHJpYnV0ZTE9Tm8KQ3VzdG9tQXR0cmlidXRlMj1ObwpDdXN0b21BdHRyaWJ1dGUzPU5vClN1YkNhcGFjaXR5RWxpZ2libGVQcm9kdWN0PU5vClRhcmdldFR5cGU9QU5ZClRhcmdldFR5cGVOYW1lPU9wZW4gVGFyZ2V0ClRhcmdldElEPUFOWQpFeHRlbmRlZFRhcmdldFR5cGU9CkV4dGVuZGVkVGFyZ2V0SUQ9ClNlcmlhbE51bWJlcj0KVXBncmFkZT1ObwpJbnN0YWxsUHJvZ3JhbT0KQ2FwYWNpdHlUeXBlPQpNYXhPZmZsaW5lUGVyaW9kPQpEZXJpdmVkTGljZW5zZVN0eWxlPQpEZXJpdmVkTGljZW5zZVN0YXJ0RGF0ZT0KRGVyaXZlZExpY2Vuc2VFbmREYXRlPQpEZXJpdmVkTGljZW5zZUFnZ3JlZ2F0ZUR1cmF0aW9uPQo="
  //  db2_cpu    = 4
  //  db2_memory = "16Gi"
  //  db2_instance_version = "11.5.6.0"
  //  db2_host_name   = "REQUIRED"
  //  db2_host_ip     = "REQUIRED"
  //  db2_port_number = "REQUIRED"
  //  db2_use_on_ocp  = true
  db2_admin_user_name = "db2inst1"
  //  cp4ba_deployment_platform     = local.platform_options
  //  db2_on_ocp_storage_class_name = local.sc_fast_file_storage_classname
  //  db2_storage_size              = "150Gi"
  db2_project_name = "ibm-db2"
}

// Portworx Module Variables
//variable "install_portworx" {
//  type        = bool
//  default     = false
//  description = "Install Portworx on the ROKS cluster. `true` or `false`"
//}

locals {
  //  cp4ba_namespace              = "cp4ba"
  entitled_registry_key_secret_name = "ibm-entitlement-key"
  docker_secret_name                = "docker-registry"
  docker_server                     = "cp.icr.io"
  docker_username                   = "cp"
  docker_password                   = chomp(var.entitlement_key)
  docker_email                      = var.entitled_registry_user_email

  enable_cluster = var.cluster_name_or_id == "" || var.cluster_name_or_id == null
  //  use_entitlement              = "yes"
  project_name     = "cp4ba"
  platform_options = 1     // 1: roks - 2: ocp - 3: private cloud
  deployment_type  = 2     // 1: demo - 2: enterprise
  platform_version = "4.6" // roks version

  //  entitled_registry_key        = chomp(var.entitlement_key)
  ibmcloud_api_key = chomp(var.ibmcloud_api_key)
}

variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for Business Automation on the given cluster"
}