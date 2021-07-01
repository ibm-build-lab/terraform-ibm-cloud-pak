# Creation of a Partner Sandbox

This documentation is **<u>only for developers or advanced users</u>**. Sandbox **users** please refer to [Installer Script](../installer/README.md) documentation.

This folder contains the Infrastructure as Code or Terraform code to create a **Sandbox** with an **Openshift** (ROKS) cluster on IBM Cloud and additional Cloud Paks. At this time the supported components are:

- ROKS stand alone cluster in either VPC or Classic
- Automation Foundation (IAF)
- Cloud Pak for Applications (CP4App)
- Cloud Pak for Automation (CP4Auto)
- Cloud Pak for Data (CP4Data)
- Cloud Pak for Integration (CP4Int)
- Cloud Pak for Multi Cloud Management (CP4MCM)

Everything is automated with Makefiles. However, instructions to get the same results manually are provided.

- [Creation of a Partner Sandbox](#creation-of-a-partner-sandbox)
  - [Requirements](#requirements)
  - [Configure Access to IBM Cloud](#configure-access-to-ibm-cloud)
    - [Create an IBM Cloud API Key](#create-an-ibm-cloud-api-key)
    - [Create an IBM Cloud Classic Infrastructure API Key](#create-an-ibm-cloud-classic-infrastructure-api-key)
    - [Create the credentials file](#create-the-credentials-file)
  - [Provisioning the Sandbox](#provisioning-the-sandbox)
  - [Design](#design)
    - [External Terraform Modules](#external-terraform-modules)

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
  - `oc`

Execute these commands to validate some of these requirements:

```bash
ibmcloud --version
ibmcloud plugin show schematics | head -3
ibmcloud plugin show kubernetes-service | head -3
ibmcloud target
terraform version
ls ~/.terraform.d/plugins/terraform-provider-ibm_*
```

## Configure Access to IBM Cloud

Terraform requires the IBM Cloud credentials to access IBM Cloud. The credentials can be set using environment variables or - optionally and recommended - in your own `credentials.sh` file.

### Create an IBM Cloud API Key

Follow these instructions to setup the **IBM Cloud API Key**, for more information read [Creating an API key](https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key).

In a terminal window, execute following commands replacing `<RESOURCE_GROUP_NAME>` with the resource group where you are planning to work and install everything:

```bash
ibmcloud login --sso
ibmcloud resource groups
ibmcloud target -g <RESOURCE_GROUP_NAME>
```

If you have an IBM Cloud API Key that is either not set or you don't have the JSON file when it was created, you must recreate the key. Delete the old one if it won't be in use anymore.

```bash
ibmcloud iam api-keys       # Identify your old API Key Name
ibmcloud iam api-key-delete NAME
```

Create new key

```bash
ibmcloud iam api-key-create TerraformKey -d "API Key for Terraform" --file ~/.ibm_api_key.json
export IC_API_KEY=$(grep '"apikey":' ~/.ibm_api_key.json | sed 's/.*: "\(.*\)".*/\1/')
```

### Create an IBM Cloud Classic Infrastructure API Key

Follow these instructions to get the **Username** and **API Key** to access **IBM Cloud Classic**, for more information read [Managing classic infrastructure API keys](https://cloud.ibm.com/docs/account?topic=account-classic_keys).

1. At the IBM Cloud web console, go to **Manage** > **Access (IAM)** > **API keys**, and select **Classic infrastructure API keys** in the dropdown menu.
2. Click Create a classic infrastructure key. If you don't see this option, check to see if you already have a classic infrastructure API key that is created because you're only allowed to have one in the account per user.
3. Go to the actions menu (3 vertical dots) to select **Details**, then **Copy** the API Key.
4. Go to **Manage** > **Access (IAM)** > **Users**, then search and click on your user's name. Select **Details** at the right top corner to copy the **User ID** from the users info (it may be your email address).

### Create the credentials file

In the terminal window, export the following environment variables to let the IBM Provider to retrieve the credentials.

```bash
export IAAS_CLASSIC_USERNAME="< Your IBM Cloud Username/Email here >"
export IAAS_CLASSIC_API_KEY="< Your IBM Cloud Classic API Key here >"
export IC_API_KEY="< IBM Cloud API Key >"
```

So as to not have to define them for every new terminal, you can create the file `credentials.sh` containing the above credentials.

Execute the file like so:

```bash
source credentials.sh
```

Additionally, you can append the above `export` commands in your shell profile or config file (i.e. `~/.bashrc` or `~/.zshrc`) and they will be executed on every new terminal.

**IMPORTANT**: If you use a different filename than `credentials.sh` make sure to not commit the file to GitHub. The filename `credentials.sh` is in the `.gitignore` file so it is safe to use it..

## Provisioning the Sandbox

To build the Sandbox with a selected Cloud Pak on IBM Cloud Classic the available methods are:

- **[Using Make](./Using_Make.md)**: With the use of `make` and the existing `Makefiles` it is possible to provision the Cloud Pak locally with Terraform, or remotely with Schematics. Make is the recommended way if this is your first time or to get things done quickly. Refer to [Using Make](./Using_Make.md) for instructions.
- **[Using Terraform](./Using_Terraform.md)**: The Makefile contains all the Terraform actions/commands to run, however you can execute them manually whenever you want, even after using `make` initially. This option allows you to customize the input parameters and offers more control of the process. Refer to [Using Terraform](./Using_Terraform.md) for instructions.
- **[Using Schematics](./Using_Schematics.md)**: The Makefile contains all the commands to provision a Cloud Pak using IBM Cloud Schematics, however you can do it manually using `ibmcloud` cli or the IBM Cloud Web Console to create and manage a Schematics workspace. Consider using `make` to - at least - create the workspace, it can save you some time. Refer to [Using Schematics](./Using_Schematics.md) for instructions.
- **[Using IBM Cloud CLI](./Using_IBMCloud_CLI.md)**: The existing Terraform code provisions an OpenShift cluster then installs the requested Cloud Pak on it. With the IBM Cloud CLI you cannot install a Cloud Pak but you can provision an OpenShift cluster to install the Cloud Pak on using any of the above methods. Instructions to provision an OpenShift cluster using the CLI are in the [Using IBM Cloud CLI](./Using_IBMCloud_CLI.md) document.
- **[Using a Private Catalog](./Using_Private_Catalog.md)**: (Deprecated) It's possible to have a Private Catalog as a user interface with the Schematics and Terraform code, however this option may be more complex than creating a Schematics workspace. This option is not supported anymore. Instructions to create a Private Catalog are in the [Using Private Catalog](./Using_Private_Catalog.md) document.

## Design

This directory contains the Terraform HCL code to execute/apply by Terraform either locally or by remotely, by IBM Cloud Schematics. The code to provision each specific Cloud Pak is located in a separate subdirectory. They each have almost the same design, input and output parameters and very similar basic validation.

Each Cloud Pak subdirectory contains the following files:

- `main.tf`: contains the code provision the Cloud Pak, you should start here to know what Terraform does. This uses two Terraform modules: the ROKS module and a Cloud Pak module. The ROKS module is used to provision an OpenShift cluster where the Cloud Pak will be installed. Then the Cloud Pak module is applied to install the Cloud Pak. To know more about these Terraform modules refer to the following section [Cloud Pak External Terraform Modules](#cloud-pak-external-terraform-modules).
- `variables.tf`: contains all the input parameters. The input parameters are explained below but you can get additional information about them in the README of each Cloud Pak directory.
- `outputs.tf`: contains all the output parameters. The output parameters are explained below but you can get additional information about them in the README of each Cloud Pak directory.
- `terraform.tfvars`: although the `variables.tf` defines the input variables and the default values, the `terraform.tfvars` also contains default values to access and modify. If you'd like to customize your resources try to modify the values in this file first.
- `workspace.tmpl.json`: this is a template file used by the `terraform/Schematics.mk` makefile to generate the `workspace.json` file which is used to create the IBM Cloud Schematics workspace. The template contains, among other data, the URL of the repository where the Terraform is located and the input parameters with default values. The generated JSON file contains the entitlement key. This file is not included in the repo and is ignored by GitHub (listed it in the `.gitignore` file).
- `Makefile`: most of the Makefile logic is located in the `terraform/` makefiles (`Makefile` and `*.mk` files) however some specific actions for the Cloud Pak are required, for example, the Cloud Pak validations. All these specific actions are in this `Makefile`.

The Input and Output parameters, as well as basic validations and uninstall process can be found in the README of each component, refer to the following links below:

- [ROKS](./roks/README.md)
- [Automation Foundation](./iaf/README.md)
- [Cloud Pak for Applications](./cp4app/README.md)
- [Cloud Pak for Automation](./cp4auto/README.md)
- [Cloud Pak for Data](./cp4data/README.md)
- [Cloud Pak for Integration](./cp4int/README.md)
- [Cloud Pak for Multi Cloud Management](./cp4mcm/README.md)

The Makefiles in the `terraform/` directory help you to do the provisioning of the desired Cloud Pak, they also helps to document the process in case you'd like to do everything manually. The instructions about how to use the Makefile is in the document [Using Make](./Using_Make.md).

In a nutshell the Makefiles provision a Cloud Pak either using your local Terraform or the remote Schematics service. The former is recommended when you are developing or modifying the Terraform code. Use the later when you are ready to deploy the code and want to verify everything will work for the Installer script.

Both processes will create a set of files to facilitate the provisioning. The Terraform process creates the `my_variables.auto.tfvars` with automatically generated variables such as the owner, entitlement key and cluster id if you have one. The Schematics process creates the `workspace.json` file from the template to generate the Schematics workspace. The Schematics process is the most similar to what the Installer will do but step by step, so you, as developer or advance user, can validate and debug the entire process.

### External Terraform Modules

As mentioned above, the `main.tf` file in each subdirectory uses two Terraform modules: the ROKS and the Cloud Pak module. To know more about these modules refer to their [GitHub repository](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak).

Note: All these modules will be registered in the Terraform Registry so they will be easy to access. This will be part of a future release that will include the Terraform 0.13/0.14 upgrade.
