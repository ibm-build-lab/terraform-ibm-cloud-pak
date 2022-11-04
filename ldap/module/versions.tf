terraform {
  required_version = ">= 1.0.0"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
}
