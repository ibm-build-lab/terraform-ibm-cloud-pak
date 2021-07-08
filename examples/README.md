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

For instructions to run Schematics from IBM Cloud UI or using the cli, go to **[Using Schematics](./Using_Schematics.md)**

For more information, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

## Run using local Terraform Client

To run using the local Terraform Client on your local machine follow these steps:

### Requirements

To run locally, these examples have the following dependencies:

- Have an IBM Cloud account with required privileges
- [Install IBM Cloud CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-ibm-cloud-cli)
- [Install the IBM Cloud CLI Plugins](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#ibm-cloud-cli-plugins) `schematics` and `kubernetes-service`.
- [Login to IBM Cloud with the CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#login-to-ibm-cloud)
- [Install Terraform](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-terraform) **version 0.12**
- [Install IBM Cloud Terraform Provider](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#configure-access-to-ibm-cloud)
- [Configure Access to IBM Cloud](#configure-access-to-ibm-cloud)
- Utility tools such as:
  - [jq](https://stedolan.github.io/jq/download/)
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

### Configure Access to IBM Cloud

Terraform requires the IBM Cloud credentials to access IBM Cloud. The credentials can be set using environment variables or - optionally and recommended - saved in a `credentials.sh` file.

#### Create an IBM Cloud API Key

Follow these instructions to setup the **IBM Cloud API Key**, for more information read [Creating an API key](https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key).

In a terminal window, execute following commands replacing `<RESOURCE_GROUP_NAME>` with the resource group where you are planning to work and install everything:

```bash
ibmcloud login --sso -g <RESOURCE_GROUP_NAME>
```

If you have an **IBM Cloud API Key** that is either not set or you don't have the JSON file when it was created, you must recreate the key. Delete the old one if it won't be in use anymore.

```bash
ibmcloud iam api-keys       # Identify your old API Key Name
ibmcloud iam api-key-delete NAME
```

Create new key

```bash
ibmcloud iam api-key-create TerraformKey -d "API Key for Terraform" --file ~/.ibm_api_key.json
export IC_API_KEY=$(grep '"apikey":' ~/.ibm_api_key.json | sed 's/.*: "\(.*\)".*/\1/')
```

#### Create an IBM Cloud Classic Infrastructure API Key

Follow these instructions to get the **Username** and **API Key** to access **IBM Cloud Classic**, for more information read [Managing classic infrastructure API keys](https://cloud.ibm.com/docs/account?topic=account-classic_keys).

1. At the IBM Cloud web console, go to **Manage** > **Access (IAM)** > **API keys**, and select **Classic infrastructure API keys** in the dropdown menu.
2. Click Create a classic infrastructure key. If you don't see this option, check to see if you already have a classic infrastructure API key that is created because you're only allowed to have one in the account per user.
3. Go to the actions menu (3 vertical dots) to select **Details**, then **Copy** the API Key.
4. Go to **Manage** > **Access (IAM)** > **Users**, then search and click on your user's name. Select **Details** at the right top corner to copy the **User ID** from the users info (it may be your email address).

#### Create the credentials file

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

## Executing the examples

   1. Move into the directory of the desired example to install:

      ```bash
      cd iaf
      ```

   2. Create the file `terraform.tfvars` with the following Terraform input variables using your own specific values.  Refer to each example README for the specific variables to override:

      ```hcl
      ibmcloud_api_key             = "******************************"
      on_vpc                       = "false"
      config_dir                   = ".kube/config"
      cluster_id                   = "************************"
      entitled_registry_user_email = "John.Smith@ibm.com"
      entitled_registry_key        = "****************************"
      resource_group               = "Default"
      ...
      ```

   3. Issue the following commands to prime the Terraform code:

      ```bash
      terraform init
      ```

      If you modified the code, execute the following commands to validate and format the code:

      ```bash
      terraform fmt -recursive
      terraform validate
      terraform plan
      ```

   4. Issue the following command to execute the Terraform code:

      ```bash
      terraform apply -auto-approve
      ```

      At the end of the execution you'll see the output parameters.

      If something fails, it should be safe to execute the `terraform apply` command again.

   5. To get the output parameters again or validate them, execute:

      ```bash
      terraform output
      ```

   6. Finally, when you finish using the infrastructure, cleanup everything you created with the execution of:

      ```bash
      terraform destroy
      ```

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


