# Using the Cloud Pak Terraform module examples

This folder used to contain examples using the Infrastructure as Code or Terraform modules located [here](../modules).  However, these examples have now been moved down into each module directory. 

These examples will install Cloud Paks and supporting utilities on an existing **Openshift** (ROKS) cluster on IBM Cloud. To get to the examples, follow the links:

- [ROKS stand alone cluster in either VPC or Classic](../modules/roks/example)
- [Portworx on VPC (on ROKS 4.6)](../modules/portworx/example/README.md)
- [ODF on VPC (on ROKS 4.7+)](../modules/odf/example/)
- [LDAP on Classic (used for CP4BA and CP4S)](../modules/ldap/example/)
- [DB2 Database (used for CP4BA)](../modules/db2/example)
- [Cloud Pak for AIOps (CP4AIOPS)](../modules/cp4aiops/examples/)
- [Cloud Pak for Business Automation (CP4BA)](../modules/cp4ba/example/)
- [Cloud Pak for Data 4.0 (CP4Data)](../modules/cp4d_4.0/example/)
- [Cloud Pak for Integration (CP4Int)](../modules/cp4i/examples/)
- [Cloud Pak for Network Automation (CP4NA)](../modules/cp4na/example/)
- [Cloud Pak for Security (CP4S)](../modules/cp4s/examples/)

## Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](../Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

**NOTE:** LDAP and CP4Security can not be run from Schematics due to manual steps required.

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md)

## Design

This directory contains the Terraform HCL code to execute/apply by Terraform either locally or by remotely, by IBM Cloud Schematics. The code to provision each specific Cloud Pak is located in a separate subdirectory. They each have almost the same design, input and output parameters and very similar basic validation.

Each Cloud Pak subdirectory contains the following files:

- `main.tf`: contains the code provision the Cloud Pak. This file contains resources to get the configuration of the input ROKS cluster. Then the Cloud Pak module is applied to install the Cloud Pak.
- `variables.tf`: contains all the input parameters. The input parameters are documented in the README of each example directory.
- `outputs.tf`: contains all the output parameters. The output parameters are documented in the README of each Cloud Pak example.
- `versions.tf`: sets up the TF versions
- **Optional**`terraform.tfvars`: although the `variables.tf` defines the input variables and the default values, the `terraform.tfvars` also contains default values to access and modify. If you'd like to customize your resources try to modify the values in this file first.


