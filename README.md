# IBM Terraform Modules to install Cloud Paks

This repository contains a collection of Terraform modules to be used to install Cloud Paks.

- [IBM Terraform Modules to handle Cloud Paks](#ibm-terraform-modules-to-handle-cloud-paks)
  - [Modules](#modules)
  - [Usage](#usage)
    - [Building a ROKS cluster](#building-a-roks-cluster)
    - [Using an existing ROKS cluster](#using-an-existing-roks-cluster)
    - [Enable and Disable Cloud Pak Modules](#enable-and-disable-cloud-pak-modules)
    - [Examples](#examples)
  - [Testing](#testing)
  - [Owners](#owners)

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

## Usage

To use a module, define the `ibm` provisioner block with the `region` and - optionally - the `generation` (**1 for Classic** and **2 for VPC Gen 2**).

```hcl
provider "ibm" {
  generation = 1
  region     = "us-south"
}
```

## Set up access to IBM Cloud 
Go [here](./CREDENTIALS.md) for details.

You can define the IBM Cloud credentials in the IBM provider block but it is recommended to pass them in as environment variables. 

**NOTE**: These credentials are not required if running this Terraform code within an **IBM Cloud Schematics** workspace. They are automatically set from your account.

### Building a ROKS cluster

To build the cluster in your code, use the `module` resource and set the `source` to the location of the **roks** module (GitHub link in the table above). Then pass the input parameters with the cluster specification. Full examples provided in the [Examples](#examples) section below.

```hcl
module "cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks"
  ...
}
```

The output parameters of the ROKS module can be used as input parameters to the Cloud Pak module however, there may be some dependency issues depending of the resources in your code. If you experience some of these issues it is recommended to use the data resource `ibm_container_cluster_config` to get the cluster configuration and pass its output to the Cloud Pak module. This is explained in the following section.

### Using an existing ROKS cluster

To use an existing OpenShift cluster add a code similar to the following to get the cluster configuration:

```hcl
data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = var.cluster_name_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = true
  config_dir        = "./kube/config"     // Create the directory in advance
  admin             = false
  network           = false
}
```

The variable `cluster_name_id` can have either the cluster name or ID. The resource group where the cluster is running is also required. Use the data resource `ibm_resource_group` to get the ID from the resource group name.

The output parameters of the cluster configuration data resource `ibm_container_cluster_config` are used as input parameters for any Cloud Pak module.

### Enable and Disable Cloud Pak Modules
**NOTE**: To utilize any of the Cloud Pak Terraform modules an OpenShift cluster is required. This can be an existing cluster or can provisioned using the RedHat OpenShift Service (**roks**) Terraform module.

In Terraform the block parameter `count` is used to define how many instances of the resource are needed, including zero, meaning the resource won't be created. The `count` parameter on `module` blocks is only available since Terraform version 0.13.

If you are using Terraform 0.12 the workaround is the input parameter `enable`. Each module has the `enable` boolean input parameter with default value `true`. If the `enable` parameter is set to `false` the Cloud Pak is not installed. Use the `enable` parameter only if using Terraform 0.12 or lower, this parameter may be deprecated when Terraform 0.12 is not longer supported.

### Examples

To install CP4MCM in a previously provisioned cluster, the code may look like this:

```hcl
data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.group.id
  config_dir        = var.config_dir
}

module "cp4mcm" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4mcm"

  // ROKS cluster parameters:
  openshift_version   = local.roks_version
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  install_infr_mgt_module      = true
  install_operations_module    = true
}
```

To build an OpenShift cluster on IBM VPC and install CP4APP on it, the code may be like this:

```hcl
module "cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks"

  on_vpc         = true
  project_name   = "cp4app"
  owner          = var.owner
  environment    = "demo"

  resource_group       = var.resource_group
  roks_version         = "4.4"
  flavors              = ["c3c.16x32"]
  workers_count        = [5]
  datacenter           = var.datacenter
  force_delete_storage = true
}

module "cp4app" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4app"

  cluster_config_path          = module.cluster.config.config_file_path
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email
}
```

If you are getting errors because the cluster configuration is incorrect or unavailable, the solution may be to use the data resource `ibm_container_cluster_config` to get the provisioned cluster configuration. Similar to the example for CP4MCM above.

## Testing

Each module has a `testing` directory to test changes to the module manually before committing them. You can also use the testing code as documentation to know how to use the module.

To run any module test, just go to the `testing` directory, set/export required environment variables such as the IBM Cloud credentials, the entitled registry parameters, etc.., then run `make`, like this:

```bash
cd testing
# export environment variables
make
make test-kubernetes
make clean
```

For more information about testing, such as what environment variables to export, read the README on each `testing` directory of the module to test. Also, read the `Makefile` if you'd like to know more. For more information about development and contributions to the code read the [CONTRIBUTE](./CONTRIBUTE.md) document.

And ... don't forget to keep the Terraform code format clean and readable.

```bash
terraform fmt -recursive
```

## Owners

Each module has the file `OWNER.md` with the collaborators working actively on this module. Although this project and modules are open source, and everyone can and is encourage to contribute, the module owners are responsible for the merging process. Please, contact them for any questions.
