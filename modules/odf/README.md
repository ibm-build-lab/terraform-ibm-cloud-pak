# Terraform Module to install Openshift Data Foundation on a VPC cluster

This Terraform Module installs the **ODF Service** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/odf`

- [Terraform Module to install Openshift Data Foundation](#terraform-module-to-install-cloud-pak-for-multi-cloud-management)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Provisioning this module in a Terraform Script](#provisioning-this-module-in-a-terraform-script)
    - [Setting up the OpenShift cluster](#setting-up-the-openshift-cluster)
    - [Installing ODF Module](#provisioning-the-odf-module)
  - [Input Variables](#input-variables)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Clean up](#clean-up)

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../CREDENTIALS.md) for details.

## Provisioning this module in a Terraform Script

In your Terraform code define the `ibm` provisioner block with the `region`.

```hcl
provider "ibm" {
  region     = "us-south"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
```

### Setting up the OpenShift cluster

NOTE: an OpenShift cluster is required to install this ODF service. This can be an existing cluster or can be provisioned in the Terraform script.

To provision a new cluster, refer [here](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/roks#building-a-new-roks-cluster) for the code to add to your Terraform script.

### Provisioning the ODF Module

Use a `module` block assigning `source` to `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/odf`. Then set the [input variables](#input-variables) required to install the ODF service.

```hcl
module "odf" {
  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/odf"
  enable = var.enable
  cluster_id = var.cluster_id
  roks_version = var.roks_version

  // Cluster parameters
  kube_config_path = var.kube_config_path
}
```


## Input Variables

| Name                           | Description                                                                                                                                                                                                                | Default | Required |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `enable`                       | If set to `false` does not install Portworx on the given cluster. Enabled by default | `true`  | Yes       |
| `ibmcloud_api_key`             | This requires an ibmcloud api key found here: `https://cloud.ibm.com/iam/apikeys`    |         | Yes       |
| `kube_config_path`             | This is the path to the kube config                                          |  `.kube/config` | Yes       |
| `resource_group_name`          | The resource group name where the cluster is housed                                  |         | Yes      |
| `region`                       | The region that resources will be provisioned in. Ex: `"us-east"` `"us-south"` etc.  |         | Yes      |
| `cluster_id`                   | The name of the cluster created |  | Yes       |


**NOTE** The boolean input variable `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.

For an example of how to put all this together, refer to our [Cloud Pak for Data Terraform script](https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform/cp4data).


## Executing the Terraform Script

Run the following commands to execute the TF script (containing the modules to create/use ROKS and ODF). Execution may take about 5-15 minutes:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Clean up

Work in progress



