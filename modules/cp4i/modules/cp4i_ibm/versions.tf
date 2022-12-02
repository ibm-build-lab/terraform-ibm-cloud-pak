#####################################################
# Cloud Pak for Integration
# Copyright 2022 IBM
#####################################################

terraform {
  required_version = ">= 1.0.0"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}
