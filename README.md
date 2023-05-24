# IBM Terraform Modules to install Cloud Paks

This repository contains a collection of Terraform modules to be used to install Cloud Paks.

**NOTE: These modules have been deprecated and are no longer supported.**

## Modules

| Name    | Description                                                                                      | Source                                                                  |
| ------- | ------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------- |
| [roks](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/roks/)    | Provisions an IBM OpenShift managed cluster in Classic or VPC infrastructure. An OpenShift cluster is required to install any Cloud Pak module | `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/roks`    |
| [db2](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/Db2)  | Installs Db2 on an existing OpenShift cluster                          | `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/Db2`  |
| [ldap](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/ldap)  | Creates an LDAP                           | `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/ldap`  |
| [portworx](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/portworx)  | Installs Portworx on an existing OpenShift VPC cluster                          | `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/portworx`  |
| [odf](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/odf)  | Installs OpenShift Data Foundation Platform on an existing 4.7+ OpenShift cluster                          | `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/odf`  |
| [cp4aiops](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/cp4aiops)  | Installs the Cloud Pak for AIOps on an existing OpenShift cluster                          | `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4aiops`  |
| [cp4ba](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/cp4ba)  | Installs the Cloud Pak for Business Automation 21.0.x on an existing OpenShift cluster                          | `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4ba`  |
| [cp4d_4.0](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/cp4d_4.0) | Installs the Cloud Pak for Data 4.0.5 on an existing OpenShift cluster                                 | `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4d_4.0` |
| [cp4i](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/cp4i)  | Installs the Cloud Pak for Integration on an existing OpenShift cluster                          | `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4i`  |
| [cp4na](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/cp4na)  | Installs the Cloud Pak for Network Automation on an existing OpenShift cluster                          | `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4na`  |
| [cp4s](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/cp4s)  | Installs the Cloud Pak for Security on an existing OpenShift cluster                          | `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4s`  |

## Requirements

The use these examples, the following is required:

- Have an IBM Cloud account with required privileges
- [Install IBM Cloud CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-ibm-cloud-cli)
- [Install the IBM Cloud CLI Plugins](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#ibm-cloud-cli-plugins) `schematics` and `kubernetes-service`.
- [Login to IBM Cloud with the CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#login-to-ibm-cloud)
- [Install Terraform](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-terraform) **version 1.0**
- [Install IBM Cloud Terraform Provider](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#configure-access-to-ibm-cloud)
- [Configure Access to IBM Cloud](#configure-access-to-ibm-cloud)
- Install some utility tools such as:
  - [jq](https://stedolan.github.io/jq/download/) (optional)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
  - [oc](https://docs.openshift.com/container-platform/3.6/cli_reference/get_started_cli.html)

Execute these commands to validate some of these requirements:

```bash
ibmcloud --version
ibmcloud plugin show schematics | head -3
ibmcloud plugin show kubernetes-service | head -3
ibmcloud target
terraform version
ls ~/.terraform.d/plugins/terraform-provider-ibm_*
```

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

You can define the IBM Cloud credentials in the IBM provider block but it is recommended to pass them in as environment variables.

Go [here](./CREDENTIALS.md) for details.

**NOTE**: These credentials are not required if running this Terraform code within an **IBM Cloud Schematics** workspace. They are automatically set from your account.


## Design

This directory contains the Terraform HCL code to execute/apply by Terraform either locally or by remotely, by IBM Cloud Schematics. The code to provision each specific Cloud Pak is located in a separate subdirectory. They each have almost the same design, input and output parameters and very similar basic validation.

Each Cloud Pak subdirectory contains the following files:

- `main.tf`: contains the code provision the Cloud Pak, you should start here to know what Terraform does.
- `variables.tf`: contains all the input parameters. You can get additional information about them in the README of each directory.
- `outputs.tf`: contains all the output parameters. You can get additional information about them in the README of each directory.
- `versions.tf`: sets up the TF versions

## Provisioning the Cloud Pak Modules

To run these modules, you will need to run the `example` we have provided for each module.  For links to get to these, go [here](../examples)

### Using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](./Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

**NOTE:** LDAP can not be run from Schematics due to manual steps required.

### Using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](./Using_Terraform.md)

## Owners

Each module has the file `OWNER.md` with the collaborators working actively on this module. Although this project and modules are open source, and everyone can and is encourage to contribute, the module owners are responsible for the merging process. Please, contact them for any questions.

## Contributing

For more information about development and contributions to the code read the [CONTRIBUTE](./CONTRIBUTE.md) document.

And ... don't forget to keep the Terraform code format clean and readable.

```bash
terraform fmt -recursive
```
