provider "ibm" {
}

// Module:
module "odf" {
  source = "./.."
  enable = var.enable
  cluster = var.cluster
  ibmcloud_api_key = var.ibmcloud_api_key
}

