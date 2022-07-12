#####################################################
# Cloud Pak for Integration
# Copyright 2022 IBM
#####################################################

terraform {
  required_version = ">= 0.13"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">=1.34"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}
