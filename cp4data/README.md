# Terraform Module to install Cloud Pak for Data

This Terraform Module installs **Cloud Pak for Data** on an existing Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4data`

- [Terraform Module to install Cloud Pak for Data](#terraform-module-to-install-cloud-pak-for-data)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Usage](#usage)
    - [Building a new ROKS cluster](#building-a-new-roks-cluster)
    - [Using an existing ROKS cluster](#using-an-existing-roks-cluster)
    - [Installing the CP4DATA Module](#installing-the-cp4data-module)
  - [Input Variables](#input-variables)
  - [Executing the modules](#executing-the-modules)
  - [Accessing the Cloud Pak Console](#accessing-the-cloud-pak-console)
  - [Clean up](#clean-up)
  
## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../CREDENTIALS.md) for details.

## Usage

In your Terraform code define the `ibm` provisioner block with the `region` and the `generation`, which is **1 for Classic** and **2 for VPC Gen 2**. Optionally you can define the IBM Cloud credentials parameters or (recommended) pass them in environment variables.

```hcl
provider "ibm" {
  generation = 1
  region     = "us-south"
}
```

NOTE: an OpenShift cluster is required to install the cloud pak. This can be an existing cluster or can be provisioned in the TF code.  See both examples below.

### Building a new ROKS cluster

To build the cluster in your TF script, use the [roks](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/roks) module, set `source` to `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks` and include the input parameters with the cluster specification required install `cp4data`.

For Cloud Pak for Data the recommended parameters are a `classic` 4.5+ OpenShift cluster with `4` workers of type `b3c.16x64`, however read the Cloud Pak for Data documentation to confirm these parameters or if you are using IBM Cloud VPC or a different OpenShift version.

```hcl
module "cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks"

  on_vpc         = false
  project_name   = "cp4data"
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

The variable `cluster_name_id` can contain either the cluster name or ID. The resource group where the cluster is running is also required, for this one use the `data` resource `ibm_resource_group`.

The output parameters of the `ibm_container_cluster_config` resource are used as input parameters for the `cp4data` module.

### Installing the CP4DATA Module

Create a `module` block and assign `source` to `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4data`. Then pass the input parameters (documented [here](#input-variables)) required to install the required Cloud Pak for Data.

```hcl
module "cp4data" {
  source          = "./.."
  enable          = true

  // ROKS cluster parameters:
  openshift_version   = var.roks_version
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // Parameters to install CPD modules
  install_watson_knowledge_catalog = var.install_watson_knowledge_catalog
  install_watson_studio            = var.install_watson_studio
  install_watson_machine_learning  = var.install_watson_machine_learning
  install_watson_open_scale        = var.install_watson_open_scale
  install_data_virtualization      = var.install_data_virtualization
  install_streams                  = var.install_streams
  install_analytics_dashboard      = var.install_analytics_dashboard
  install_spark                    = var.install_spark
  install_db2_warehouse            = var.install_db2_warehouse
  install_db2_data_gate            = var.install_db2_data_gate
  install_rstudio                  = var.install_rstudio
  install_db2_data_management      = var.install_db2_data_management
}
```

**NOTE** To enable/disable the module, a boolean input parameter `enable` with default value `true` is used. If the `enable` parameter is set to `false` the Cloud Pak is not installed. This parameter may be deprecated when Terraform 0.12 is not longer supported.

In Terraform 0.13, the block parameter `count` can be used to define how many instances of the resource are needed. If set to zero the resource won't be created (module won't be installed).

## Input Variables

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `enable`                           | If set to `false` does not install the cloud pak on the given cluster. By default it's enabled                                                                                                                        | `true`                      | No       |
| `openshift_version`                | Openshift version installed in the cluster                                                                                                                                                                                 | `4.5`                       | No       |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |                             | Yes      |
| `storage_class_name`               | Storage Class name to use                                                                                                                                                                                                  | `ibmc-file-custom-gold-gid` | No       |
| `install_watson_knowledge_catalog` | Install Watson Knowledge Catalog module. By default it's not installed.                                                                                                                                                    | `false`                     | No       |
| `install_watson_studio`            | Install Watson Studio module. By default it's not installed.                                                                                                                                                               | `false`                     | No       |
| `install_watson_machine_learning`  | Install Watson Machine Learning module. By default it's not installed.                                                                                                                                                     | `false`                     | No       |
| `install_watson_open_scale`        | Install Watson Open Scale module. By default it's not installed.                                                                                                                                                           | `false`                     | No       |
| `install_data_virtualization`      | Install Data Virtualization module. By default it's not installed.                                                                                                                                                         | `false`                     | No       |
| `install_streams`                  | Install Streams module. By default it's not installed.                                                                                                                                                                     | `false`                     | No       |
| `install_analytics_dashboard`      | Install Analytics Dashboard module. By default it's not installed.                                                                                                                                                         | `false`                     | No       |
| `install_spark`                    | Install Analytics Engine powered by Apache Spark module. By default it's not installed.                                                                                                                                    | `false`                     | No       |
| `install_db2_warehouse`            | Install DB2 Warehouse module. By default it's not installed.                                                                                                                                                               | `false`                     | No       |
| `install_db2_data_gate`            | Install DB2 Data_Gate module. By default it's not installed.                                                                                                                                                               | `false`                     | No       |
| `install_rstudio`                  | Install RStudio module. By default it's not installed.                                                                                                                                                                     | `false`                     | No       |
| `install_db2_data_management`      | Install DB2 Data Management module. By default it's not installed.                                                                                                                                                         | `false`                     | No       |

## Executing the modules

After setting all the input parameters, execute the following commands

```bash
terraform init
terraform plan
terraform apply
```

## Accessing the Cloud Pak Console

After around _20 to 30 minutes_ you can access the cluster using `kubectl` or `oc`. To get the console URL, open a Cloud Shell and issue the following commands:

```bash
ibmcloud oc cluster config -c <cluster-name> --admin
kubectl get route -n ibm-common-services cp-console -o jsonpath=‘{.spec.host}’ && echo
```

To get default login id:

```bash
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}\' | base64 -d && echo
```

To get default Password:

```bash
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d && echo
```

## Clean up

When you finish using the cluster, you can release the resources executing the following command, it should finish in about _8 minutes_:

```bash
terraform destroy
```

