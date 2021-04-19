# Licensed Source of IBM Copyright IBM Corp. 2020, 2021
provider "ibm" {
  generation = 2
  ibmcloud_api_key = var.ibmcloud_api_key
  region = var.dc_region
}