variable "cluster_id" {
  default     = ""
  description = "If you have an existing cluster, use the cluster ID or name. If left blank, a new Openshift cluster will be provisioned"
}

variable "entitlement" {
  default     = ""
  description = "Ignored if `cluster_id` is specified. Enter 'cloud_pak' if using a Cloud Pak entitlement.  Leave blank if OCP entitlement"
}

variable "on_vpc" {
  type        = bool
  default     = false
  description = "Ignored if `cluster_id` is specified. Type of infrastructure should cluster be? Options are `true` = VPC, `false` classic"
}

variable "region" {
  default     = "us-south"
  description = "Ignored if `cluster_id` is specified. List all available regions with: `ibmcloud regions`"
}

variable "resource_group" {
  default     = "cloud-pak-sandbox"
  description = "Ignored if `cluster_id` is specified. List all available resource groups with: `ibmcloud resource groups`"
}

variable "roks_version" {
  default     = "4.6"
  description = "Ignored if `cluster_id` is specified. List available versions: `ibmcloud ks versions`"
}

variable "project_name" {
  default     = "roks"
  description = "Ignored if `cluster_id` is specified. The project name is used to name the cluster with the environment name"
}

variable "owner" {
  default     = "anonymous"
  description = "Optional. User name or team name. The owner is used to label the cluster and other resources"
}

variable "environment" {
  default     = "dev"
  description = "Ignored if `cluster_id` is specified.  The environment name is used to name the cluster with the project name"
}

variable "force_delete_storage" {
  type        = bool
  default     = true
  description = "Ignored if `cluster_id` is specified. If set to true, force the removal of persistent storage associated with the cluster during cluster deletion. Default value is false"
}

// OpenShift cluster specific input parameters and default values:
variable "flavors" {
  type    = list(string)
  default = ["b3c.16x64"]
  description = "Ignored if `cluster_id` is specified. Array with the flavors or machine types of each of the workers. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2` or `ibmcloud ks flavors --zone dal10 --provider classic`. On Classic only list one flavor, i.e. `[\"b3c.16x64\"]`. On VPC can list multiple flavors `[\"mx2.4x32\", \"mx2.8x64\", \"cx2.4x8\"] or [\"mx2.4x32\"]`"
}

variable "workers_count" {
  type    = list(number)
  default = [4]
  description = "Ignored if `cluster_id` is specified. Array with the amount of workers on each workers group. Classic only takes the first number of the list. Example: [1, 3, 5]. Note: number of elements must equal number of elements in flavors array"
}

variable "private_vlan_number" {
  default     = ""
  description = "Ignored if `cluster_id` is specified. Classic Only. Private VLAN assigned to zone. List available VLANs in the zone: ibmcloud ks vlan ls --zone, make sure the the VLAN type is private and the router begins with bc. Use the ID or Number"
}

variable "public_vlan_number" {
  default     = ""
  description = "Ignored if `cluster_id` is specified. Classic Only. Public VLAN assigned to zone. List available VLANs in the zone: ibmcloud ks vlan ls --zone, make sure the the VLAN type is public and the router begins with fc. Use the ID or Number"
}

variable "datacenter" {
  default = "dal12"
  description = "Ignored if `cluster_id` is specified. Classic Only. List all available datacenters/zones with: 'ibmcloud ks zone ls --provider classic'"
}

variable "vpc_zone_names" {
  type    = list(string)
  default = ["us-south-1"]
  description = "Ignored if `cluster_id` is specified. VPC only. Array with the subzones in the region to create the workers groups. List all the zones with: 'ibmcloud ks zone ls --provider vpc-gen2'. Example [\"us-south-1\", \"us-south-2\", \"us-south-3\"]"
}

variable "config_dir" {
  default     = "./.kube/config"
  description = "Directory to store the kubeconfig file, set the value to empty string to not download the config"
}

// Portworx Variables

variable "install_portworx" {
  type        = bool
  default     = false
  description = "Install Portworx on the ROKS cluster. `true` or `false`"
}

variable "portworx_is_ready" {
  type = any
  default = null
}

variable "ibmcloud_api_key" {
  description = "Ignored if Portworx is not enabled: IBMCloud API Key for the account the resources will be provisioned on. This is need for Portworx. Go here to create an ibmcloud_api_key: https://cloud.ibm.com/iam/apikeys"
}

variable "storage_capacity"{
    type = number
    default = 200
    description = "Ignored if Portworx is not enabled: Storage capacityin GBs"
}

variable "storage_profile" {
    type = string
    default = "10iops-tier"
    description = "Ignored if Portworx is not enabled. Optional, Storage profile used for creating storage"
}

variable "storage_iops" {
    type = number
    default = 10
    description = "Ignored if Portworx is not enabled. Optional, Used only if a user provides a custom storage_profile"
}

variable "create_external_etcd" {
    type = bool
    default = false
    description = "Ignored if Portworx is not enabled: Do you want to create an external etcd database? `true` or `false`"
}

# These credentials have been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.
# You may override these for additional security.
variable "etcd_username" {
  default = ""
  description = "Ignored if Portworx is not enabled: This has been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.  Override these for additional security."
}

variable "etcd_password" {
  default = ""
  description = "Ignored if Portworx is not enabled: This has been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.  Override these for additional security."
}

// ======= CP4Data Variables ========
variable "entitled_registry_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Docker email address"
}

variable "cpd_project_name" {
  type        = string
  default     = "default"
  description = "Name of the project namespace"
}

variable "accept_cpd_license" {
  type        = bool
  description = "Do you accept the cpd license agreements? This includes any modules chosen as well. `true` or `false`"
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


// ROKS Module : Local Variables and constansts

locals {
  entitled_registry_key_file = "./entitlement.key"
}