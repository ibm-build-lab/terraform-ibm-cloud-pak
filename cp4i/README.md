# Terraform Module to install Cloud Pak for Integration

This Terraform Module install **Cloud Pak for Integration** on an existing Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4i`

- [Terraform Module to install Cloud Pak for Integration](#terraform-module-to-install-cloud-pak-for-integration)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Usage](#usage)
    - [Building a new ROKS cluster](#building-a-new-roks-cluster)
    - [Using an existing ROKS cluster](#using-an-existing-roks-cluster)
    - [Using the CP4I Module](#using-the-cp4i-module)
  - [Executing the TF Scripts](#executing-the-tf-scripts)
  - [Clean up](#clean-up)
  - [Input Variables](#input-variables)

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../CREDENTIALS.md) for details.

## Usage

In your Terraform code define the `ibm` provisioner block with the `region` and the `generation`, which is **1** for **Classic** and **2** for **VPC Gen 2**. Optionally you can define the IBM Cloud credentials parameters or (recommended) pass them in environment variables.

```hcl
provider "ibm" {
  generation = 1
  region     = "us-south"
}
```

NOTE: an OpenShift cluster is required to install Multi Cloud Management. This can be an existing cluster or can be provisioned in the TF code.  See both examples below.

### Building a new ROKS cluster

To build the cluster in your TF script, use the [roks](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/roks) module, set `source` to `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks` and include the input parameters with the cluster specification required to install `cp4i`.

The recommended parameters for a cluster on IBM Cloud Classic and OpenShift 4.5 or latest, is to have `4` workers machines of type `b3c.16x64`, however read the Cloud Pak for Integration documentation to confirm these parameters or if you are using IBM Cloud VPC or a different OpenShift version.

```hcl
module "cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks"

  on_vpc         = false
  project_name   = "cp4i"
  owner          = var.owner
  environment    = "demo"

  roks_version         = "4.5"
  flavors              = ["b3c.16x64"]
  workers_count        = [4]
  force_delete_storage = true
}
```

### Using an existing ROKS cluster

To use an existing OpenShift cluster, add a code similar the following to get the cluster configuration:

```hcl
data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = var.cluster_name_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = true
  config_dir        = "./kube/config"     // Create this directory in advance
  admin             = false
  network           = false
}
```

Create the `./kube/config` directory if it doesn't exist.

The variable `cluster_name_id` can contain either the cluster name or ID. The resource group where the cluster is running is also required, for this one use the data resource `ibm_resource_group`.

The output parameters of the cluster configuration data resource `ibm_container_cluster_config` are used as input parameters for the `cp4i` module.

### Using the CP4I Module

Use the `module` block assigning the `source` parameter to the location of this module, either local (i.e. `../cp4i`) or remote (`git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4i`). Then pass the input parameters (documented [here](#input-variables)) required to install the required Cloud Pak for Integration and modules.

```hcl
module "cp4i" {
  source          = "./.."
  enable          = true

  // ROKS cluster parameters:
  openshift_version   = var.roks_version
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email
}
```

**NOTE**: To enable/disable the module, a boolean input parameter `enable` with default value `true` is used. If the `enable` parameter is set to `false` the Cloud Pak is not installed. This parameter may be deprecated when Terraform 0.12 is not longer supported.

In Terraform 0.13, the block parameter `count` can be used to define how many instances of the resource are needed. If set to zero the resource won't be created (module won't be installed).

## Executing the TF Scripts

To execute the TF script (containing the modules to create/use ROKS and Cloud Pak):

```bash
terraform init
terraform plan
terraform apply
```

## Clean up

```bash
terraform destroy
```

## Input Variables

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `enable`                           | If set to `false` does not install the cloud pak on the given cluster. By default it's enabled                                                                                                                        | `true`                      | No       |
| `openshift_version`                | Openshift version installed in the cluster                                                                                                                                                                                 | `4.5`                       | No       |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |                             | Yes      |
