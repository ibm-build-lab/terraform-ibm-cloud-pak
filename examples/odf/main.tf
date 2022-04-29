provider "ibm" {
}

// Module:
module "odf" {
  source = "./.."
  is_enable = var.is_enable
  cluster = var.cluster
  ibmcloud_api_key = var.ibmcloud_api_key
}
