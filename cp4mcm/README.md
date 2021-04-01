# Terraform Module to install Cloud Pak for Multi Cloud Management

This Terraform Module installs the **Multi Cloud Management Cloud Pak** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4mcm`

- [Terraform Module to install Cloud Pak for Multi Cloud Management](#terraform-module-to-install-cloud-pak-for-multi-cloud-management)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Usage](#usage)
    - [Building a new ROKS cluster](#building-a-new-roks-cluster)
    - [Using an existing ROKS cluster](#using-an-existing-roks-cluster)
    - [Installing the CP4MCM Module](#installing-the-cp4mcm-module)
    - [Enable or Disable the Module](#enable-or-disable-the-module)
    - [Testing](#testing)
    - [Executing the TF Scripts](#executing-the-tf-scripts)
    - [Clean up](#clean-up)
  - [Input Variables](#input-variables)
  - [Output Variables](#output-variables)

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

NOTE: an OpenShift cluster is required to install the cloud pak. This can be an existing cluster or can be provisioned in the TF code.  See both examples below.

### Building a new ROKS cluster

To build the cluster in your TF script, use the [roks](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/roks) module, set `source` to `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks` and include the input parameters with the cluster specification required to install `cp4mcm`.

For Cloud Pak for MCM the recommended parameters are a `classic` 4.5+ OpenShift cluster with `5` workers of type `c3c.16x32`, however read the [Cloud Pak for Multi Cloud Management](https://www.ibm.com/support/knowledgecenter/en/SSFC4F_2.2.0/install/requirements.html) documentation to confirm these parameters.

```hcl
module "cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks"
  
  on_vpc         = false
  project_name   = "cp4mcm"
  owner          = var.owner
  environment    = "demo"

  resource_group       = var.resource_group  
  roks_version         = "4.5"
  flavors              = ["c3c.16x32"]
  workers_count        = [5]
  force_delete_storage = true
}
```

### Using an existing ROKS cluster

To use an existing OpenShift cluster, add code similar the following to get the cluster configuration:

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

The output parameters of the `ibm_container_cluster_config` resource are used as input parameters for the `cp4mcm` module.
### Installing the CP4MCM Module

Create a `module` block and assign `source` to `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4mcm`. Then pass the input parameters (documented [here](#input-variables)) required to install Cloud Pak for Multi Cloud Management and modules.

```hcl
module "cp4mcm" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4mcm"
  enable = true

  // ROKS cluster parameters:
  openshift_version   = local.roks_version
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path

  entitled_registry_key        = file("${path.cwd}/entitlement.key")
  entitled_registry_user_email = var.entitled_registry_user_email

  install_infr_mgt_module      = false
  install_monitoring_module    = false
  install_security_svcs_module = false
  install_operations_module    = false
  install_tech_prev_module     = false
}
```

### Enable or Disable the Module

To enable/disable the module, a boolean input parameter `enable` with default value `true` is used. If the `enable` parameter is set to `false` the Cloud Pak is not installed. This parameter may be deprecated when Terraform 0.12 is not longer supported.

In Terraform 0.13, the block parameter `count` can be used to define how many instances of the resource are needed. If set to zero the resource won't be created (module won't be installed).

### Testing

To manually run a module test before committing the code:

- go to the `testing` subdirectory
- follow instructions [here](testing/README.md)

The testing code provides an example on how to use the module.

### Executing the TF Scripts

To execute the TF script (containing the modules to create/use ROKS and Cloud Pak):

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

After around _20 to 30 minutes_ you can access the cluster using `kubectl` or `oc`:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output namespace)

# All resources
kubectl get all --namespace $(terraform output namespace)
```

Then, using the following credentials you can open the dashboard in a browser using the `endpoint` output parameter as URL.

```bash
terraform output user
terraform output password

open "http://$(terraform output endpoint)"
```

### Clean up

To clean up or remove CP4MCM and its dependencies from a cluster, execute the following commands:

```bash
kubectl delete -n openshift-operators subscription.operators.coreos.com ibm-management-orchestrator
kubectl delete -n openshift-marketplace catalogsource.operators.coreos.com ibm-management-orchestrator opencloud-operators
kubectl delete namespace cp4mcm
```

**Note**: The uninstall/cleanup up process is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successfully re-installation. This process will be included in the Terraform code.

When you finish using the cluster, you can release the resources executing the following command, it should finish in about _8 minutes_:

```bash
terraform destroy
```

## Input Variables

| Name                           | Description                                                                                                                                                                                                                | Default | Required |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `enable`                       | If set to `false` does not install the cloud pak on the given cluster. By default it's enabled                                                                                                      | `true`  | No       |
| `cluster_config_path`          | The path on your local machine where the cluster configuration file and certificates are downloaded to                                                                                                                     |         | Yes      |
| `openshift_version`            | Openshift version installed in the cluster                                                                                                                                                                                 |         | Yes      |
| `entitled_registry_key`        | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |         | Yes      |
| `entitled_registry_user_email` | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |         | Yes      |
| `install_infr_mgt_module`      | Install the Infrastructure Management module                                                                                                                                                                               | `false` | No       |
| `install_monitoring_module`    | Install the Monitoring module                                                                                                                                                                                              | `false` | No       |
| `install_security_svcs_module` | Install the Security Services module                                                                                                                                                                                       | `false` | No       |
| `install_operations_module`    | Install the Operations module                                                                                                                                                                                              | `false` | No       |
| `install_tech_prev_module`     | Install the Tech Preview module                                                                                                                                                                                            | `false` | No       |

## Output Variables

Once the Terraform execution completes, use the following output variables to access CP4MCM Dashboard:

| Name        | Description                                                     |
| ----------- | --------------------------------------------------------------- |
| `endpoint`  | URL of the dashboard                                     |
| `user`      | Username to log in to the dashboard                       |
| `password`  | Password to log in to the dashboard                       |
| `namespace` | Kubernetes namespace where all the componenents are installed |
