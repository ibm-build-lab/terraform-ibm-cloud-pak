#####################################################
# classic openshift single-zone cluster with CP4S
# Copyright 2022 IBM
#####################################################

variable "project_name" {
  default     = "cp4s"
  description = "Used to tag the cluster i.e. 'project:{project_name}'"
}

variable "environment" {
  default     = "dev"
  description = "Used to tag the cluster i.e. 'env:{environment}'"
}

variable "owner" {
  default     = ""
  description = "Used to tag the cluster i.e. 'owner:{owner}'"
}

variable "region" {
  description = "The region where the cluster will be created. List all available regions with: `ibmcloud regions`"
  type        = string
}

variable "resource_group" {
  description = "Enter Name of the resource group"
  default     = "Default"
  type        = string
}

variable "worker_zone" {
  description = "The data center where the worker node is created. List all available zones with `ibmcloud ks locations`"
  default     = "us-south"
  type        = string
}

variable "workers_count" {
  description = "Number of worker nodes per zone"
  type        = number
  default     = 5
}

variable "worker_pool_flavor" {
  description = "The machine type for your worker node."
  type        = string
  default     = "c3c.16x32"
}

variable "public_vlan" {
  description = "The ID of the public VLAN that you want to use for your worker nodes. List available VLANs in the zone: `ibmcloud target -g <resource-group>; ibmcloud ks vlan ls --zone <zone>`"
  type        = string
  default     = null
}

variable "private_vlan" {
  description = "The ID of the private VLAN that you want to use for your worker nodes. List available VLANs in the zone: `ibmcloud target -g <resource-group>; ibmcloud ks vlan ls --zone <zone>`"
  type        = string
  default     = null
}

variable "hardware" {
  description = "The level of hardware isolation for your worker node."
  type        = string
  default     = "shared"
}

variable "master_service_public_endpoint" {
  description = "Enable the public service endpoint to make the master publicly accessible."
  type        = bool
  default     = true
}

variable "entitlement" {
  description = "create your cluster with existing entitlement"
  type        = string
  default     = "cloud_pak"
}

variable "force_delete_storage" {
  description = "force the removal of persistent storage associated with the cluster during cluster deletion."
  type        = bool
  default     = null
}

variable "roks_version" {
  description = "The OpenShift version that you want to set up in your cluster."
  type        = string
  default     = "4.8"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Email address of the user owner of the Entitled Registry Key"
}

variable "entitled_registry_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "config_dir" {
  type        = string
  description = "Path to store cluster config file. If using schematics, set to /tmp/.schematics/.kube/config"
  default     = "./.kube/config"
}

variable "namespace" {
  type        = string
  description = "Project to install Cloud Pak in"
  default     = "cp4s"
}

variable "admin_user" {
  type = string
  description = "value of ldap admin uid"
  default     = "admin"
}


locals {
  cluster_name = "${var.project_name}-${var.environment}-${random_string.this.result}"
  roks_version = format("%s_openshift", split("_", var.roks_version)[0])
}