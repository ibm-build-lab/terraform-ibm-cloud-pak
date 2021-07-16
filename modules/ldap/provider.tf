variable "ibmcloud_api_key" {}
variable "region" {}
variable "iaas_classic_api_key" {}
variable "iaas_classic_username" {}
variable "ssh_public_key_file" {}
variable "ssh_private_key_file" {}
variable "classic_datacenter" {}

provider "ibm" {
    ibmcloud_api_key   = var.ibmcloud_api_key
    region = var.region
    iaas_classic_api_key   = var.iaas_classic_api_key
    iaas_classic_username = var.iaas_classic_username
    ssh_public_key_file = var.ssh_public_key_file
    ssh_private_key_file = var.ssh_private_key_file

   }
