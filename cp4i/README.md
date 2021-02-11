# Terraform Module to install Cloud Pak for Data

This Terraform Module install **Cloud Pak for Data** on an existing Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4data`

- [Terraform Module to install Cloud Pak for Data](#terraform-module-to-install-cloud-pak-for-data)
  - [Use](#use)
    - [Building a ROKS cluster](#building-a-roks-cluster)
    - [Using an existing ROKS cluster](#using-an-existing-roks-cluster)
    - [Enable or Disable the Module](#enable-or-disable-the-module)
    - [Using the CP4DATA Module](#using-the-cp4data-module)
  - [Input Variables](#input-variables)
  - [Output Variables](#output-variables)

## Use

In your Terraform code define the `ibm` provisioner block with the `region` and the `generation`, which is **1 for Classic** and **2 for VPC Gen 2**. Optionally you can define the IBM Cloud credentials parameters or (recommended) pass them in environment variables.

```hcl
provider "ibm" {
  generation = 1
  region     = "us-south"
}
```

Export the environment variables for the credentials like so:

```bash
# Credentials required only for IBM Cloud Classic
export IAAS_CLASSIC_USERNAME="< Your IBM Cloud Username/Email here >"
export IAAS_CLASSIC_API_KEY="< Your IBM Cloud Classic API Key here >"

# Credentials required for IBM Cloud VPC and Classic
export IC_API_KEY="< IBM Cloud API Key >"
```

_Running this Terraform code from IBM Cloud Schematics don't require to set these parameters, they are set automatically from your account by IBM Cloud Schematics._

Before using the Cloud Pak for Data module it's required to have an OpenShift cluster, this could be an existing cluster or you can provision it in your code using the ROKS module.

### Building a ROKS cluster

To build the cluster in your code, use the ROKS module, pointing it with `source` to the location of this module (`git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks`). Then pass the input parameters with the cluster specification required to run the cp4data module.

```hcl
module "cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks"

  roks_version         = "4.5"
  flavors              = ["b3c.16x64"]
  workers_count        = [4]
  force_delete_storage = true

  ...
}
```

The recommended parameters for a cluster on IBM Cloud Classic and OpenShift 4.5 or latest, is to have `4` workers machines of type `b3c.16x64`, however read the Cloud Pak for Data documentation to confirm these parameters or if you are using IBM Cloud VPC or a different OpenShift version.

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

The variable `cluster_name_id` can have either the cluster name or ID. The resource group where the cluster is running is also required, for this one use the data resource `ibm_resource_group`.

The output parameters of the cluster configuration data resource `ibm_container_cluster_config` are used as input parameters for the DATA Cloud Pak module.

### Enable or Disable the Module

In Terraform the block parameter `count` is used to define how many instances of the resource are needed, including zero, meaning the resource won't be created. The `count` parameter on `module` blocks is only available since Terraform version 0.13.

Using Terraform 0.12 the workaround is to use the boolean input parameter `enable` with default value `true`. If the `enable` parameter is set to `false` the Cloud Pak for DATA is not installed. Use the `enable` parameter only if using Terraform 0.12 or lower, this parameter may be deprecated when Terraform 0.12 is not longer supported.

### Using the CP4DATA Module

Use the `module` block assigning the `source` parameter to the location of this module, either local (i.e. `../cp4data`) or remote (`git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4data`). Then pass the input parameters required to install the required Cloud Pak for Data version and their modules.

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

After setting all the input parameters execute the following commands to create the cluster

```bash
terraform init
terraform plan
terraform apply
```

After around _20 to 30 minutes_ you can configure `kubectl` or `oc` to access the cluster executing:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output namespace)

# All resources
kubectl get all --namespace $(terraform output namespace)
```

When you finish using the cluster, you can release the resources executing the following command, it should finish in about _8 minutes_:

```bash
terraform destroy
```

## Input Variables

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `enable`                           | If set to `false` does not install Cloud-Pak for Data on the given cluster. By default it's enabled                                                                                                                        | `true`                      | No       |
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

## Output Variables

Once the Terraform code finish use the following output variables to access CP4DATA Dashboard:

| Name        | Description                                                      |
| ----------- | ---------------------------------------------------------------- |
| `namespace` | Kubernetes namespace where all the CP4DATA objects are installed |
| `endpoint`  | URL to access Cloud Pak for Data                                 |
| `username`  | Username to access Cloud Pak for Data                            |
| `password`  | PAssword to access Cloud Pak for Data                            |
