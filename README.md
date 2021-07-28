# IBM Terraform Modules to install Cloud Paks

This repository contains a collection of Terraform modules to be used to install Cloud Paks.

- [IBM Terraform Modules to install Cloud Paks](#ibm-terraform-modules-to-install-cloud-paks)
  - [Modules](#modules)
  - [Requirements](#requirements)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Provisioning the Cloud Pak Modules](#provisioning-the-cloud-pak-modules)
  - [Testing](#testing)
  - [Owners](#owners)
  - [Contributing](#contributing)

These modules are used by Terraform scripts in [this](https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform) directory.

## Modules

| Name    | Description                                                                                      | Source                                                                  |
| ------- | ------------------------------------------------------------------------------------------------ | ----------------------------------------------------------------------- |
| [roks](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/roks)    | Provision an IBM OpenShift managed cluster. An OpenShift cluster is required to install any Cloud Pak module | `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks`    |
| [cp4mcm](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/cp4mcm)  | Installs the Cloud Pak for MultiCloud Management on an existing OpenShift cluster                | `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4mcm`  |
| [cp4app](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/cp4app)  | Installs the Cloud Pak for Applications  on an existing OpenShift cluster                        | `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4app`  |
| [cp4auto](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/cp4auto)  | Installs the Cloud Pak for Automation  on an existing OpenShift cluster                          | `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4auto`  |
| [cp4data](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/cp4data) | Installs the Cloud Pak for Data on an existing OpenShift cluster                                 | `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4data` |
| [cp4i](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/cp4i)  | Installs the Cloud Pak for Integration on an existing OpenShift cluster                          | `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4i`  |
| [iaf](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/iaf)  | Installs the IBM Automation Foundation on an existing OpenShift cluster                          | `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//iaf`  |
| [portworx](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/portworx)  | Installs Portworx on an existing OpenShift cluster                          | `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//portworx`  |

## Requirements

The development and testing of the sandbox setup code requires the following elements:

- Have an IBM Cloud account with required privileges
- [Install IBM Cloud CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-ibm-cloud-cli)
- [Install the IBM Cloud CLI Plugins](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#ibm-cloud-cli-plugins) `schematics` and `kubernetes-service`.
- [Login to IBM Cloud with the CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#login-to-ibm-cloud)
- [Install Terraform](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-terraform) **version 0.12**
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

## Provisioning the Cloud Pak Modules

Refer to `<module>/README.md` for specific details on how to invoke the module from a Terraform Script.

## Testing

Some of the modules provide a testing directory. To manually run a module test before committing the code:

- go to the `<module>/testing` subdirectory
- following instructions in `<module>/testing/README.md`

The testing code provides an example on how to use the module.

## Owners

Each module has the file `OWNER.md` with the collaborators working actively on this module. Although this project and modules are open source, and everyone can and is encourage to contribute, the module owners are responsible for the merging process. Please, contact them for any questions.

## Contributing

For more information about development and contributions to the code read the [CONTRIBUTE](./CONTRIBUTE.md) document.

And ... don't forget to keep the Terraform code format clean and readable.

```bash
terraform fmt -recursive
```
