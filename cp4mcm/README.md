# Terraform Module to install Cloud Pak for Multi Cloud Management

This Terraform Module installs the **Multi Cloud Management Cloud Pak** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4mcm`

- [Terraform Module to install Cloud Pak for Multi Cloud Management](#terraform-module-to-install-cloud-pak-for-multi-cloud-management)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Provisioning this module in a Terraform Script](#provisioning-this-module-in-a-terraform-script)
    - [Setting up the OpenShift cluster](#setting-up-the-openshift-cluster)
    - [Installing the CP4MCM Module](#installing-the-cp4mcm-module)
  - [Input Variables](#input-variables)
  - [Testing](#testing)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Output Variables](#output-variables)
  - [Accessing the Cloud Pak Console](#accessing-the-cloud-pak-console)
  - [Clean up](#clean-up)

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../CREDENTIALS.md) for details.

## Provisioning this module in a Terraform Script

In your Terraform code define the `ibm` provisioner block with the `region` and the `generation`, which is **1 for Classic** and **2 for VPC Gen 2**.

```hcl
provider "ibm" {
  generation = 1
  region     = "us-south"
}
```

### Setting up the OpenShift cluster

NOTE: an OpenShift cluster is required to install the cloud pak. This can be an existing cluster or can be provisioned in the Terraform script.

To provision a new cluster, refer [here](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/roks#building-a-new-roks-cluster) for the code to add to your Terraform script. The recommended size for an OpenShift 4.5+ cluster on IBM Cloud Classic contains `5` workers of type `c3c.16x32`, however read the [Cloud Pak for Multi Cloud Management](https://www.ibm.com/docs/en/cloud-paks/cp-management) documentation to confirm these parameters or if you are using IBM Cloud VPC or a different OpenShift version.

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

`ibm_container_cluster_config` used as input for the `cp4mcm` module.

### Installing the CP4MCM Module

Use a `module` block assigning `source` to `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4mcm`. Then set the [input variables](#input-variables) required to install the Cloud Pak for Multi Cloud Management and submodules.

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

## Input Variables

| Name                           | Description                                                                                                                                                                                                                | Default | Required |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `enable`                       | If set to `false` does not install the cloud pak on the given cluster. Enabled by default                                                                                                      | `true`  | No       |
| `cluster_config_path`          | The path on your local machine where the cluster configuration file and certificates are downloaded to                                                                                                                     |         | Yes      |
| `openshift_version`            | Openshift version installed in the cluster                                                                                                                                                                                 |         | Yes      |
| `entitled_registry_key`        | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |         | Yes      |
| `entitled_registry_user_email` | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |         | Yes      |
| `install_infr_mgt_module`      | Install the Infrastructure Management module                                                                                                                                                                               | `false` | No       |
| `install_monitoring_module`    | Install the Monitoring module                                                                                                                                                                                              | `false` | No       |
| `install_security_svcs_module` | Install the Security Services module                                                                                                                                                                                       | `false` | No       |
| `install_operations_module`    | Install the Operations module                                                                                                                                                                                              | `false` | No       |
| `install_tech_prev_module`     | Install the Tech Preview module                                                                                                                                                                                            | `false` | No       |

**NOTE** The boolean input variable `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.

For an example of how to put all this together, refer to our [Cloud Pak for Multi Cloud Management Terraform script](https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform/cp4mcm).

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

## Output Variables

Once the Terraform execution completes, use the following output variables to access CP4MCM Dashboard:

| Name        | Description                                                     |
| ----------- | --------------------------------------------------------------- |
| `endpoint`  | URL of the dashboard                                     |
| `user`      | Username to log in to the dashboard                       |
| `password`  | Password to log in to the dashboard                       |
| `namespace` | Kubernetes namespace where all the componenents are installed |

## Accessing the Cloud Pak Console

After execution has completed, access the cluster using `kubectl` or `oc`:

```bash
ibmcloud ks cluster config -cluster $(terraform output cluster_id)
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

## Clean up

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




