terraform {
  required_version = ">= 1.0.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}
