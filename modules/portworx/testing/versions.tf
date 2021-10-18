terraform {
  required_version = ">= 0.13"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "~> 1.34"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}