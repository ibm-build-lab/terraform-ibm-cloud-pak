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

variable "resource_group" {
//  name       = "cloud-pak-sandbox-ibm"
  description = "Resource group name where the cluster will be hosted."
}

variable "registry_server" {
  description = "Enter the public image registry or route (e.g., default-route-openshift-image-registry.apps.<hostname>).\nThis is required for docker/podman login validation:"
}

variable "entitlement_key" {
  type        = string
  description = "Do you have a Cloud Pak for Business Automation Entitlement Registry key? If not, Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "public_image_registry" {
  description = "Have you pushed the images to the local registry using 'loadimages.sh' (CP4BA images)? If not, Please pull the images to the local images to proceed."
}

variable "public_registry_server" {
  description = "public image registry or route for docker/podman login validation: \n (e.g., default-route-openshift-image-registry.apps.<hostname>). This is required for docker/podman login validation: "
}

variable "registry_user" {
  description = "Enter the user name for your docker registry: "
}

variable "registry_password" {
  description = "Enter the password for your docker registry: "
}

variable "region" {
  description = "Region where the cluster is created"
}



locals {
  cp4ba_namespace              = "cp4ba-project"
  entitled_registry            = "cp.icr.io"
  entitled_registry_user       = "cp"
  enable_cluster               = var.cluster_name_id == "" || var.cluster_name_id == null
  use_entitlement              = "yes"
  project_name                 = "cp4ba-project"
  platform_options             = 1 // 1: roks - 2: ocp - 3: private cloud
  deployment_type              = 2 // 1: demo - 2: enterprise
  platform_version             = "4.6" // roks version

  entitled_registry_key        = chomp(var.entitlement_key)
  ibmcloud_api_key             = chomp(var.ibmcloud_api_key)
 }

locals {
  storage_class_name               = "cp4a-file-retain-gold-gid"
  sc_slow_file_storage_classname   = "cp4a-file-retain-bronze-gid"
  sc_medium_file_storage_classname = "cp4a-file-retain-silver-gid"
  sc_fast_file_storage_classname   = "cp4a-file-retain-gold-gid"
}
