variable "region" {}
variable "resource_group_name" {}
variable "cluster_id" {}

variable "on_vpc" {
  default     = false
  type        = bool
  description = "If set to true, lets the module know cluster is using VPC Gen2"
}

variable "accept_cpd_license" {
  type        = bool
  description = "Do you accept the cpd license agreements? This includes any modules chosen as well. `true` or `false`"
}

// Prereq
variable "worker_node_flavor" {
  type        = string
  description = "Flavor used to determine worker node hardware"
}

variable "entitled_registry_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Docker email address"
}

// Modules available to install on CP4D

variable "install_watson_knowledge_catalog" {
  default     = false
  type        = bool
  description = "Install Watson Knowledge Catalog module. Only for Cloud Pak for Data v3.5"
}
variable "install_watson_studio" {
  default     = false
  type        = bool
  description = "Install Watson Studio module. Only for Cloud Pak for Data v3.5"
}
variable "install_watson_machine_learning" {
  default     = false
  type        = bool
  description = "Install Watson Machine Learning module. Only for Cloud Pak for Data v3.5"
}
variable "install_watson_open_scale" {
  default     = false
  type        = bool
  description = "Install Watson Open Scale module. Only for Cloud Pak for Data v3.5"
}
variable "install_data_virtualization" {
  default     = false
  type        = bool
  description = "Install Data Virtualization module. Only for Cloud Pak for Data v3.5"
}
variable "install_streams" {
  default     = false
  type        = bool
  description = "Install Streams module. Only for Cloud Pak for Data v3.5"
}
variable "install_analytics_dashboard" {
  default     = false
  type        = bool
  description = "Install Analytics Dashboard module. Only for Cloud Pak for Data v3.5"
}
variable "install_spark" {
  default     = false
  type        = bool
  description = "Install Analytics Engine powered by Apache Spark module. Only for Cloud Pak for Data v3.5"
}
variable "install_db2_warehouse" {
  default     = false
  type        = bool
  description = "Install DB2 Warehouse module. Only for Cloud Pak for Data v3.5"
}
variable "install_db2_data_gate" {
  default     = false
  type        = bool
  description = "Install DB2 Data_Gate module. Only for Cloud Pak for Data v3.5"
}
variable "install_rstudio" {
  default     = false
  type        = bool
  description = "Install RStudio module. Only for Cloud Pak for Data v3.5"
}
variable "install_db2_data_management" {
  default     = false
  type        = bool
  description = "Install DB2 Data Management module. Only for Cloud Pak for Data v3.5"
}

variable "install_big_sql" {
  default     = false
  type        = bool
  description = "Install Big SQL module. Only for Cloud Pak for Data v3.5"
}
locals {
  cluster_config_path = "./.kube/config"
}
