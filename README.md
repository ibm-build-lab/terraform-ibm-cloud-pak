# IBM Terraform Modules to handle Cloud Paks

This repository contain a collection of Terraform modules to be used to handle Cloud Paks.

## Modules

| Name   | Description                                                                                      | Source                                                                 |
| ------ | ------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------- |
| ROKS   | Provision an OpenShift cluster. An OpenShift cluster is required to install any Cloud Pak module | `git::https://github.com/ibm-pett/terraform-ibm-cloud-pak.git//roks`   |
| CP4MCM | Install MultiCloud Management Cloud Pak on an existing OpenShift cluster                         | `git::https://github.com/ibm-pett/terraform-ibm-cloud-pak.git//cp4mcm` |
| CP4APP | Install Applications Cloud Pak on an existing OpenShift cluster                                  | `git::https://github.com/ibm-pett/terraform-ibm-cloud-pak.git//cp4app` |

## Use

To use a module it's required to define the `ibm` provisioner block with the `region` and - optionally - the `generation`, which is **1 for Classic** and **2 for VPC Gen 2**.

```hcl
provider "ibm" {
  generation = 1
  region     = "us-south"
}
```

You can define the IBM Cloud credentials parameters in the IBM provider block but it's recommended to pass them in environment variables. Export the environment variables for the credentials like so:

```bash
# Credentials required only for IBM Cloud Classic
export IAAS_CLASSIC_USERNAME="< Your IBM Cloud Username/Email here >"
export IAAS_CLASSIC_API_KEY="< Your IBM Cloud Classic API Key here >"

# Credentials required for IBM Cloud VPC and Classic
export IC_API_KEY="< IBM Cloud API Key >"
```

_Running this Terraform code from IBM Cloud Schematics don't require to set these parameters, they are set automatically from your account by IBM Cloud Schematics._

Before using any of the Cloud Pak modules it's required to have an OpenShift cluster, this could be an existing cluster or you can provision it in your code.

### Building a ROKS cluster

To build the cluster in your code, use the ROKS module, using the `module` resource pointing the `source` to the location of this module (GitHub link in the table above). Then pass the input parameters with the cluster specification.

```hcl
module "cluster" {
  source = "github.com/ibm-pett/terraform-ibm-cloud-pak/roks"
  ...
}
```

**IMPORTANT**: The output parameters of the ROKS module are used as input parameters to the Cloud Pak module to use however, at this time it recommended to not pass the parameters from the module, instead use the data resource `ibm_container_cluster_config` to get the cluster configuration and pass it to the module. This is explained in the following section.

### Using an existing ROKS cluster

To use an existing OpenShift cluster add a code similar the following to get the cluster configuration:

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

The variable `cluster_name_id` can have either the cluster name or ID. The resource group where the cluster is running is also required, use the data resource `ibm_resource_group` to get the ID from the resource group name.

The output parameters of the cluster configuration data resource `ibm_container_cluster_config` are used as input parameters for the Cloud Pak module to use and install.

### Enable and Disable CP Modules

In Terraform the block parameter `count` is used to define how many instances of the resource are needed, including zero, meaning the resource won't be created. The `count` parameter on `module` blocks is only available since Terraform version 0.13.

Using Terraform 0.12 the workaround is to use the input parameter `enable`. Each module has the `enable` boolean input parameter with default value `true`. If the `enable` parameter is set to `false` the Cloud Pak is not installed. Use the `enable` parameter only if using Terraform 0.12 or lower, this parameter may be deprecated when Terraform 0.12 is not longer supported.

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
  source = "github.com/ibm-pett/terraform-ibm-cloud-pak/cp4mcm"

  // ROKS cluster parameters:
  resource_group    = var.resource_group
  openshift_version = var.k8s_version
  cluster_config = {
    host               = data.ibm_container_cluster_config.cluster_config.host
    client_certificate = data.ibm_container_cluster_config.cluster_config.admin_certificate
    client_key         = data.ibm_container_cluster_config.cluster_config.admin_key
    token              = data.ibm_container_cluster_config.cluster_config.token
    config_file_path   = data.ibm_container_cluster_config.cluster_config.config_file_path
  }

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  ...
}
```

To build an OpenShift cluster on IBM VPC and install CP4APP on it, the code may be like this:

```hcl
module "cluster" {
  source = "github.com/ibm-pett/terraform-ibm-cloud-pak/roks"

  on_vpc         = true
  project_name   = "cp4app"
  roks_version   = "4.4"
  ...

  // Kubernetes Config variables:
  download_config = true
  config_dir      = "./.kube/config"

  ...
}

module "cp4app" {
  source = "github.com/ibm-pett/terraform-ibm-cloud-pak/cp4app"

  // ROKS cluster parameters:
  cluster_config_path          = module.cluster.config.config_file_path

  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email
  ...
}
```

**IMPORTANT**: If you are getting errors because the cluster configuration is incorrect or unavailable, the solution may be to use the data resource `ibm_container_cluster_config` to get the provisioned cluster configuration. Similar to the example for CP4MCM above.

## Testing

Each module has the `testing` directory to test the module manually (before commit any code change) and to be used by the CI/CD pipeline. You can also use the testing code to know how to use the module or to use it directly (not recommended but the option is there).

In a nutshell, to run any module test, just go to the `testing` directory, set/export - if required - some environment variables and run `make`, like this:

```bash
cd testing
# export some environment variables
make
make test-kubernetes
make clean
```

For more information about testing read the README on each `testing` directory of the module to test. For more information about development and contributions to the code read the [CONTRIBUTE](./CONTRIBUTE.md) document.

And ... don't forget to keep the Terraform code format clean and readable.

```bash
terraform fmt -recursive
```

## Owners

Each module has the file `OWNER.md` with the collaborators working actively on this module. Although this project and modules are open source, and everyone can and is encourage to contribute, the module owners are responsible for the merging process. Please, contact them for any questions.
