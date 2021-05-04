# Licensed Source of IBM Copyright IBM Corp. 2020, 2021
provider "ibm" {
  region = var.region
}

provider "kubernetes" {
  config_path = var.kube_config_path
}