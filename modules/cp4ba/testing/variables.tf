
variable "ibmcloud_api_key" {
  description = "IBM Cloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "cluster_name_id" {
  default     = ""
  description = "Enter your cluster id or name to install the Cloud Pak. Leave blank to provision a new Openshift cluster."
}

variable "entitled_registry_user_email" {
  type = string
  description = "Email address of the user owner of the Entitled Registry Key"
//  validation {
//    condition = can(regrex("^No resources found+$", var.entitled_registry_user_email))
//    error_message = "At least one user must be available in order to proceed. Please refer to the README for the requirements and instructions. The script will now exit!"
//  }
}

variable "iaas_classic_api_key" {}
variable "iaas_classic_username" {}
variable "ssh_public_key_file" {}
variable "ssh_private_key_file" {}
variable "classic_datacenter" {}

variable "config_dir" {
  default     = "./.kube/config"
  description = "directory to store the kubeconfig file"
}

variable "region" {
  description = "Region where the cluster is created"
}

variable "resource_group" {
//  name       = "cloud-pak-sandbox-ibm"
  description = "Resource group name where the cluster will be hosted."
}

variable "openshift_version" {
  default     = "4.6"
  type        = string
  description = "Openshift version installed in the cluster"
}
//
//variable "hasEntitlementKey" {
//  type        = string
//  description = "Do you have a Cloud Pak for Business Automation Entitlement Registry key (Yes/No, default: No):"
//}

variable "local_registry_server" {
  description = "Enter the public image registry or route (e.g., default-route-openshift-image-registry.apps.<hostname>).\nThis is required for docker/podman login validation:"
}

variable "portworx_is_ready" {
  type    = any
  default = null
}

variable "entitled_registry_key" {
  type        = string
//  sensitive = true
  description = "Do you have a Cloud Pak for Business Automation Entitlement Registry key? If not, Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "namespace" {
  type        = string
  description = "namespace for cp4ba"
}

variable "project_name" {
  description = "Enter a valid project name. Project name should not be 'openshift' or 'kube' or start with 'openshift' or 'kube'."
  type = string
//  validation {
//    condition = can(regex("^kube+$", var.project_name))
//    error_message = "Please enter a valid project name that should not be 'openshift' or 'kube' or start with 'openshift' or 'kube'."
//  }
}

variable "platform_options" {
  type        = number
  description = "Select the cloud platform to deploy. Enter a valid option [1 - 3]: \n 1. RedHat OpenShift Kubernetes Service (ROKS) - Public Cloud \n 2. Openshift Container Platform (OCP) - Private Cloud \n 3. Other ( Certified Kubernetes Cloud Platform / CNCF)"
}

variable "deployment_type" {
  type        = number
  description = "What type of deployment is being performed? Enter a valid option [1 to 2]: \n 1. Demo \n 2. Enterprise"
}

variable "platform_version" {
  description = "Enter the platform version"
}

variable "environment" {
  default     = "dev"
  description = "Ignored if `cluster_id` is specified. The environment is combined with `project_name` to name the cluster. The cluster name will be '{project_name}-{environment}-cluster' and all the resources will be tagged with 'env:{environment}'"
}

variable "use_entitlement" {
  type = string
  default = "yes"
}

variable "public_image_registry" {
  description = "Have you pushed the images to the local registry using 'loadimages.sh' (CP4BA images)? If not, Please pull the images to the local images to proceed."
}

variable "local_public_registry_server" {
  description = "public image registry or route for docker/podman login validation: \n (e.g., default-route-openshift-image-registry.apps.<hostname>). This is required for docker/podman login validation: "
}

variable "local_registry_user" {
  description = "Enter the user name for your docker registry: "
}

variable "local_registry_password" {
  description = "Enter the password for your docker registry: "
}

variable "on_vpc" {
  type        = bool
  default     = false
  description = "Enter cluster type to be installed on, `true` = VPC, `false` = Classic"
}

// Flavor will depend on whether classic or vpc
variable "flavors" {
  type        = list(string)
  default     = ["b3c.16x64"]
  description = "Ignored if `cluster_id` is specified. Array with the flavors or machine types of each the workers group. Classic only takes the first flavor of the list. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider <classic | vpc-gen2>`. Classic: `[\"b3c.16x64\"]`, VPC: `[\"bx2.16x64\"]`"
}

variable "workers_count" {
  type    = list(number)
  default = [5]
  description = "Ignored if `cluster_id` is specified. Array with the amount of workers on each workers group. Classic only takes the first number of the list. Example: [1, 3, 5]. Note: number of elements must equal number of elements in flavors array"
}

variable "data_center" {
  default     = "dal10"
  description = "**Classic Only**. Ignored if `cluster_id` is specified. Datacenter or Zone in the IBM Cloud Classic region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`"
}

variable "vpc_zone_names" {
  type        = list(string)
  default     = ["us-south-1"]
  description = "**VPC Only**: Ignored if `cluster_id` is specified. Zones in the IBM Cloud VPC region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider vpc-gen2`."
}

variable "private_vlan_number" {
  default     = ""
  description = "**Classic Only**. Ignored if `cluster_id` is specified. Private VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone <zone>`, make sure the the VLAN type is private and the router begins with bc. Use the ID or Number. Leave blank if Private VLAN does not exist, one will be created"
}

variable "public_vlan_number" {
  default     = ""
  description = "**Classic Only**. Ignored if `cluster_id` is specified. Public VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone <zone>`, make sure the the VLAN type is public and the router begins with fc. Use the ID or Number. Leave blank if Public VLAN does not exist, one will be created"
}

variable "storage_capacity"{
    type = number
    default = 200
    description = "Ignored if Portworx is not enabled: Storage capacity in GBs"
}

variable "storage_db2" {
    type = number
    default = 10
    description = "Ignored if Portworx is not enabled. Optional, Used only if a user provides a custom storage_profile"
}

variable "storage_profile" {
    type = string
    default = "10iops-tier"
    description = "Ignored if Portworx is not enabled. Optional, Storage profile used for creating storage"
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

variable "cluster_config_path" {
  default     = "./.kube/config"
  description = "directory to store the kubeconfig file"
}


//variable "cluster_id" {
//  default     = ""
//  description = "Enter your cluster id or name to install the Cloud Pak. Leave blank to provision a new Openshift cluster."
//}

// Portworx Module Variables
variable "install_portworx" {
  type        = bool
  default     = false
  description = "Install Portworx on the ROKS cluster. `true` or `false`"
}

locals {
  cp4ba_namespace              = "cp4ba-project"
  entitled_registry            = "cp.icr.io"
  entitled_registry_user       = "cp"
  enable_cluster               = var.cluster_name_id == "" || var.cluster_name_id == null
  use_entitlement              = var.use_entitlement #? ["yes", "Yes", "YES", "y", "Y"] : ["", "n", "N", "no", "No", "NO"]
  local_public_registry_server = var.local_public_registry_server
  local_public_image_registry  = var.public_image_registry
  local_registry_server        = var.local_registry_server
  local_registry_user          = var.local_registry_user
  local_registry_password      = var.local_registry_password
  entitled_registry_key        = chomp(var.entitled_registry_key)
  ibmcloud_api_key             = chomp(var.ibmcloud_api_key)
  openshift_version_regex      = regex("(\\d+).(\\d+)(.\\d+)*(_openshift)*", var.openshift_version)
  openshift_version_number     = local.openshift_version_regex[3] == "_openshift" ? tonumber("${local.openshift_version_regex[0]}.${local.openshift_version_regex[1]}") : 0
}

locals {
  storage_class_name               = "cp4a-file-retain-gold-gid"
  sc_slow_file_storage_classname   = "cp4a-file-retain-bronze-gid"
  sc_medium_file_storage_classname = "cp4a-file-retain-silver-gid"
  sc_fast_file_storage_classname   = "cp4a-file-retain-gold-gid"
}
