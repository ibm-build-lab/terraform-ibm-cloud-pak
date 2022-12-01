
variable "operator_namespace" {
  default = "ibm-common-services"
  description = "Namespace to install operator"
}

variable "cluster_id" {
  description = "ROKS cluster id. Use the ROKS terraform module or other way to create it"
}

variable "ibmcloud_api_key" {
  description = "IBMCloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "region" {
  description = "Region of the cluster"
}

variable "resource_group_name" {
  description = "Resource group that the cluster is created in"
}

variable "enable" {
  default     = true
  description = "If set to true installs Cloud-Pak for Data on the given cluster"
}

variable "on_vpc" {
  default     = false
  type        = bool
  description = "If set to true, lets the module know cluster is using VPC Gen2"
}

variable "cluster_config_path" {
  description = "Path to the Kubernetes configuration file to access your cluster"
}

variable "openshift_version" {
  default     = "4.10"
  description = "Openshift version installed in the cluster"
}

# variable "cluster_endpoint" {
#   default     = "not-required"
#   description = "URL to access the OpenShift cluster"
# }

variable "entitled_registry_key" {
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "accept_cpd_license" {
  type        = bool
  description = "Do you accept the cpd license agreements? This includes any modules chosen as well. `true` or `false`"
}

variable "cpd_project_name" {
  type        = string
  default     = "cp4d"
  description = "Name of the project namespace"
}
// Prereq
variable "worker_node_flavor" {
  type        = string
  description = "Flavor used to determine worker node hardware"
}

variable "portworx_is_ready" {
  type    = any
  default = null
}
// Modules available to install on CP4D

variable "empty_module_list" {
  default     = true
  type        = bool
  description = "Determine if any modules need to be installed for CP4D"
}

variable "install_wsl" {
  default     = false
  type        = string
  description = "Install WSL module. Only for Cloud Pak for Data v4.0"
}

variable "install_aiopenscale" {
  default     = false
  type        = string
  description = "Install AI Open Scale module. Only for Cloud Pak for Data v4.0"
}

variable "install_wml" {
  default     = false
  type        = string
  description = "Install Watson Machine Learning module. Only for Cloud Pak for Data v4.0"
}

variable "install_wkc" {
  default     = false
  type        = string
  description = "Install Watson Knowledge Catalog module. Only for Cloud Pak for Data v4.0"
}

variable "install_dv" {
  default     = false
  type        = string
  description = "Install Data Virtualization module. Only for Cloud Pak for Data v4.0"
}

variable "install_spss" {
  default     = false
  type        = string
  description = "Install SPSS module. Only for Cloud Pak for Data v4.0"
}

variable "install_cde" {
  default     = false
  type        = string
  description = "Install CDE module. Only for Cloud Pak for Data v4.0"
}

variable "install_spark" {
  default     = false
  type        = string
  description = "Install Analytics Engine powered by Apache Spark module. Only for Cloud Pak for Data v4.0"
}

variable "install_dods" {
  default     = false
  type        = string
  description = "Install DODS module. Only for Cloud Pak for Data v4.0"
}

variable "install_ca" {
  default     = false
  type        = string
  description = "Install CA module. Only for Cloud Pak for Data v4.0"
}

variable "install_ds" {
  default     = false
  type        = string
  description = "Install DS module. Only for Cloud Pak for Data v4.0"
}

variable "install_db2oltp" {
  default     = false
  type        = string
  description = "Install DB2OLTP module. Only for Cloud Pak for Data v4.0"
}

variable "install_db2wh" {
  default     = false
  type        = string
  description = "Install DB2WH module. Only for Cloud Pak for Data v4.0"
}

variable "install_big_sql" {
  default     = false
  type        = string
  description = "Install Big SQL module. Only for Cloud Pak for Data v4.0"
}

variable "install_wsruntime" {
  default     = false
  type        = string
  description = "Install WS Runtime. Only for Cloud Pak for Data v4.0"
}


variable "storage_option" {
  type    = string
  default = "portworx"
  description = "Choose storage type `portworx`, `odf`, or `nfs`."
}

variable "cpd_storageclass" {
  type = map(any)

  default = {
    "portworx" = "portworx-shared-gp3"
    "odf"      = "ocs-storagecluster-cephfs"
    "nfs"      = "nfs"
  }
}

variable "rwo_cpd_storageclass" {
  type = map(any)

  default = {
    "portworx" = "portworx-metastoredb-sc"
    "odf"      = "ocs-storagecluster-ceph-rbd"
    "nfs"      = "nfs"
  }
}

locals {
  namespace              = "default"
  entitled_registry      = "cp.icr.io"
  entitled_registry_user = "cp"
  entitled_registry_key  = chomp(var.entitled_registry_key)
  # ibmcloud_api_key         = chomp(var.ibmcloud_api_key)
  openshift_version_regex  = regex("(\\d+).(\\d+)(.\\d+)*(_openshift)*", var.openshift_version)
  openshift_version_number = local.openshift_version_regex[3] == "_openshift" ? tonumber("${local.openshift_version_regex[0]}.${local.openshift_version_regex[1]}") : 0
  storage_class      = lookup(var.cpd_storageclass, var.storage_option)
  rwo_storage_class  = lookup(var.rwo_cpd_storageclass, var.storage_option)
}


