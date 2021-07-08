# Using the Cloud Pak Sandbox Terraform module examples

This folder contains examples using the Infrastructure as Code or Terraform modules located [here](../modules).  These examples will install Cloud Paks on an existing **Openshift** (ROKS) cluster on IBM Cloud. At this time the supported components are:

- ROKS stand alone cluster in either VPC or Classic
- Automation Foundation (IAF)
- Cloud Pak for Automation (CP4Auto)
- Cloud Pak for Data (CP4Data)
- Cloud Pak for Integration (CP4Int)
- Cloud Pak for Multi Cloud Management (CP4MCM)
- Cloud Pak for Security

## Run using IBM Cloud Schematics

For instructions to run using IBM Schematics go [here](./Using_Schematics.md)**

For more information, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](./Using_Terraform.md)**

## Design

This directory contains the Terraform HCL code to execute/apply by Terraform either locally or by remotely, by IBM Cloud Schematics. The code to provision each specific Cloud Pak is located in a separate subdirectory. They each have almost the same design, input and output parameters and very similar basic validation.

Each Cloud Pak subdirectory contains the following files:

- `main.tf`: contains the code provision the Cloud Pak, you should start here to know what Terraform does. This uses two Terraform modules: the ROKS module and a Cloud Pak module. The ROKS module is used to provision an OpenShift cluster where the Cloud Pak will be installed. Then the Cloud Pak module is applied to install the Cloud Pak. To know more about these Terraform modules refer to the following section [Cloud Pak External Terraform Modules](#cloud-pak-external-terraform-modules).
- `variables.tf`: contains all the input parameters. The input parameters are explained below but you can get additional information about them in the README of each Cloud Pak directory.
- `outputs.tf`: contains all the output parameters. The output parameters are explained below but you can get additional information about them in the README of each Cloud Pak directory.
- `terraform.tfvars`: although the `variables.tf` defines the input variables and the default values, the `terraform.tfvars` also contains default values to access and modify. If you'd like to customize your resources try to modify the values in this file first.

The Input and Output parameters, as well as basic validations and uninstall process can be found in the README of each component, refer to the following links below:

- [ROKS](./roks/README.md)
- [Automation Foundation](./iaf/README.md)
- [Cloud Pak for Applications](./cp4app/README.md)
- [Cloud Pak for Automation](./cp4auto/README.md)
- [Cloud Pak for Data](./cp4data/README.md)
- [Cloud Pak for Integration](./cp4int/README.md)
- [Cloud Pak for Multi Cloud Management](./cp4mcm/README.md)


