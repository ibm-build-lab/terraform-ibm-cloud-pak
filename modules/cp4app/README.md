# Terraform Module to install Cloud Pak for Applications

This Terraform Module install **Applications Cloud Pak** on an existing Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4app`

- [Terraform Module to install Cloud Pak for Applications](#terraform-module-to-install-cloud-pak-for-applications)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Provisioning this module in a Terraform Script](#provisioning-this-module-in-a-terraform-script)
    - [Setting up the OpenShift cluster](#setting-up-the-openshift-cluster)
    - [Using the CP4App Module](#using-the-cp4app-module)
  - [Input Variables](#input-variables)
  - [Testing](#testing)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Output Variables](#output-variables)
    - [Accessing the Cloud Pak Console](#accessing-the-cloud-pak-console)
  - [Clean up](#clean-up)

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../../CREDENTIALS.md) for details.

## Provisioning this module in a Terraform Script

In your Terraform script define the `ibm` provisioner block with the `region` and the `generation`, which is **1** for **Classic** and **2** for **VPC Gen 2**.

```hcl
provider "ibm" {
  generation = 1
  region     = "us-south"
}
```

### Setting up the OpenShift cluster

NOTE: an OpenShift cluster is required to install the Cloud Pak. This can be an existing cluster or can be provisioned using our `roks` Terraform module.

To provision a new cluster, refer [here](../roks/README.md#building-a-new-roks-cluster) for the code to add to your Terraform script. The recommended size for an OpenShift 4.5+ cluster on IBM Cloud Classic contains `4` workers of flavor `c3c.16x32`, however read the Cloud Pak for Applications documentation to confirm these parameters or if you are using IBM Cloud VPC or a different OpenShift version.

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

`ibm_container_cluster_config` used as input for the `cp4i` module

### Using the CP4App Module

Use the `module` block assigning the `source` parameter to the location of this module, either local (i.e. `../../modules/cp4app`) or remote (`github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4auto`). Then set the [input variables](#input-variables) required to install the Cloud Pak for Applications.

```hcl
module "cp4app" {
  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4auto"
  enable = true

  entitled_registry_key        = file("${path.cwd}/entitlement.key")
  entitled_registry_user_email = var.entitled_registry_user_email
  cluster_config_path          = data.ibm_container_cluster_config.cluster_config.config_file_path
  cp4app_installer_command     = var.cp4app_installer_command
}
```

## Input Variables

| Name                           | Description                                                  | Default   | Required |
| ------------------------------ | ------------------------------------------------------------ | --------- | -------- |
| `enable`                       | If set to `false` does not install Cloud-Pak for Applications on the given cluster. By default it's enabled | `true`    | No       |
| `cluster_config_path`          | The path on your local machine where the cluster configuration file and certificates are downloaded to |           | Yes      |
| `entitled_registry_key`        | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |           | Yes      |
| `entitled_registry_user_email` | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key |           | Yes      |
| `cp4app_installer_command`     | Command to execute by the icpa installer, the most common are: `install`, `uninstall`, `check`, `upgrade` | `install` | No       |

**NOTE** The boolean input variable `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.

For an example of how to put all this together, refer to our [Cloud Pak for Appplications Terraform script](https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform/cp4app).

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
terraform apply 
```

## Output Variables

Once the Terraform code finish use the following output variables to access Applications Cloud Pak Dashboards:

| Name                    | Description                                                |
| ----------------------- | ---------------------------------------------------------- |
| `endpoint`              | URL of the cp4app dashboard                                |
| `advisor_ui_endpoint`   | URL of the Advisor UI dashboard                            |
| `navigator_ui_endpoint` | URL of the Navigator UI dashboard                          |
| `installer_namespace`   | Kubernetes namespace where the icpa installer is installed |

### Accessing the Cloud Pak Console

After execution has completed, access the cluster using `kubectl` or `oc`:

```bash
ibmcloud ks cluster config -cluster $(terraform output cluster_id)
kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output namespace)

# All resources
kubectl get all --namespace $(terraform output namespace)
```

Then, using the following URL endpoints you can open different dashboards in a browser.

```bash
terraform output user
terraform output password

open $(terraform output endpoint)
open $(terraform output advisor_ui_endpoint)
open $(terraform output navigator_ui_endpoint)
```

## Clean up

To clean up or remove cp4app and its dependencies from a cluster, assign `uninstall` to the `cp4app_installer_command` variable and execute `terraform apply`.

When you finish using the cluster, you can release the resources executing the following command, it should finish in about _8 minutes_:

```bash
terraform destroy -auto-approve
```
