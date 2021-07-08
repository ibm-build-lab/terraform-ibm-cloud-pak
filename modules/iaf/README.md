# Terraform Module to install IBM Automation Foundation

This Terraform Module installs the [**IBM Automation Foundation**](https://www.ibm.com/docs/en/automationfoundation/1.0_ent) on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/iaf`

- [Terraform Module to install IBM Automation Foundation](#terraform-module-to-install-ibm-automation-foundation)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Provisioning this module in a Terraform Script](#provisioning-this-module-in-a-terraform-script)
    - [Setting up the OpenShift cluster](#setting-up-the-openshift-cluster)
    - [Provisioning the IAF Module](#provisioning-the-iaf-module)
  - [Input Variables](#input-variables)
  - [Testing](#testing)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Clean up](#clean-up)

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../../CREDENTIALS.md) for details.

## Provisioning this module in a Terraform Script

In your Terraform code define the `ibm` provisioner block with the `region`.

```hcl
provider "ibm" {
  region     = "us-south"
}
```

### Setting up the OpenShift cluster

NOTE: an OpenShift cluster is required to install the cloud pak. This can be an existing cluster or can be provisioned in the Terraform script.

To provision a new cluster, refer [here](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/roks#building-a-new-roks-cluster) for the code to add to your Terraform script. The recommended size for an OpenShift 4.6 (required) cluster on IBM Cloud Classic contains `4` workers of type `b3c.16x64` (classic) or `bx2.16x64` (vpc), however read the [IBM Automation Foundation](https://www.ibm.com/docs/en/automationfoundation/1.0_ent?topic=installing-system-requirements) documentation to confirm these parameters.

Add the following code to get the OpenShift cluster (new or existing) configuration:

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

**NOTE**: Create the `./kube/config` directory if it doesn't exist.

Input:

- `cluster_name_id`: either the cluster name or ID.

- `ibm_resource_group`:  resource group where the cluster is running

Output:

`ibm_container_cluster_config` used as input for the `iaf` module.

### Provisioning the IAF Module

Use a `module` block assigning `source` to `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/iaf`. Then set the [input variables](#input-variables) required to install Automation Foundation. Refer [here](../../examples/iaf) for an example:

```hcl
module "iaf" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/iaf"
  enable = true

  // ROKS cluster parameters:
  openshift_version   = var.openshift_version
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc
  cluster_name_id     = var.cluster_id

  // Entitled Registry parameters:
  // 1. Get the entitlement key from: https://myibm.ibm.com/products-services/containerlibrary
  // 2. Save the key to a file, update the file path in the entitled_registry_key parameter
  entitled_registry_key        = file("${path.cwd}/../../entitlement.key")
  entitled_registry_user_email = var.entitled_registry_user_email
}
```

## Input Variables

| Name                           | Description                                                                                                                                                                                                                | Default | Required |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `enable`                       | If set to `false` does not install the cloud pak on the given cluster. Enabled by default                                                                                                      | `true`  | No       |
| `cluster_config_path`          | The path on your local machine where the cluster configuration file and certificates are downloaded to                                                                                                                     |         | Yes      |
| `openshift_version`            | Openshift version installed in the cluster                                                                                                                                                                                 |         | Yes      |
| `entitled_registry_key`        | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |         | Yes      |
| `entitled_registry_user_email` | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |         | Yes      |
| `on_vpc`                       | This will be installed on a VPC cluster  | `false` | No       |
| `cluster_name_id`                       | Name or id of cluster to install on  |  | Yes       |

**NOTE** The boolean input variable `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.

For an example of how to put all this together, refer to our [IBM Automation Foundation Terraform script](https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform/iaf).

## Testing

To manually run a module test before committing the code:

- go to the `testing` subdirectory
- follow instructions [here](testing/README.md)

The testing code provides an example of how to use the module.

## Executing the Terraform Script

Run the following commands to execute the TF script (containing the modules to create/use ROKS and Cloud Pak). Execution may take about 30 minutes:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Clean up

To clean up or remove IAF and its dependencies from a cluster, execute the following commands:

```bash
kubectl delete -n iaf subscription.operators.coreos.com ibm-automation
kubectl delete -n openshift-operators operatorgroup.operators.coreos.com iaf-group
kubectl delete -n openshift-marketplace catalogsource.operators.coreos.com opencloud-operators
kubectl delete namespace iaf
```

**Note**: The uninstall/cleanup up process is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successfully re-installation. This process will be included in the Terraform code.

When you finish using the cluster, you can release the resources executing the following command, it should finish in about _8 minutes_:

```bash
terraform destroy
```




