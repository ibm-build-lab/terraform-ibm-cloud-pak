# Terraform Module to install Portworx

This Terraform Module installs the **Portworx Service** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//portworx`

- [Terraform Module to install Portworx](#terraform-module-to-install-cloud-pak-for-multi-cloud-management)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Provisioning this module in a Terraform Script](#provisioning-this-module-in-a-terraform-script)
    - [Setting up the OpenShift cluster](#setting-up-the-openshift-cluster)
    - [Installing Portworx Module](#provisioning-the-portworx-module)
  - [Input Variables](#input-variables)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Clean up](#clean-up)

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../CREDENTIALS.md) for details.

## Provisioning this module in a Terraform Script

In your Terraform code define the `ibm` provisioner block with the `region` and the `generation`, which is **1 for Classic** and **2 for VPC Gen 2**.

```hcl
provider "ibm" {
  generation = 2
  region     = "us-south"
}
```

### Setting up the OpenShift cluster

NOTE: an OpenShift cluster is required to install this Portworx service. This can be an existing cluster or can be provisioned in the Terraform script.

To provision a new cluster, refer [here](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/roks#building-a-new-roks-cluster) for the code to add to your Terraform script.

### Provisioning the Portworx Module

Use a `module` block assigning `source` to `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//portworx`. Then set the [input variables](#input-variables) required to install the Portworx service.

```hcl
module "portworx" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//portworx"
  enable = true

  // Storage parameters
  install_storage      = true
  storage_capacity     = 200
  
  // Portworx parameters
  resource_group_name   = "default"
  dc_region             = "us-east"
  cluster_name          = "cluster-name"
  portworx_service_name = "px-service-name"
  storage_region        = "us-east-1"
  plan                  = "px-enterprise"   # "px-dr-enterprise", "px-enterprise"
  px_tags               = ["cluster-name"]
  kvdb                  = "internal"   # "external", "internal"
  secret_type           = "k8s"   # "ibm-kp", "k8s"

}
```

## Input Variables

| Name                           | Description                                                                                                                                                                                                                | Default | Required |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `enable`                       | If set to `false` does not install Portworx on the given cluster. Enabled by default                                                                                                      | `true`  | Yes       |
| `install_storage`          |  If set to `false` does not install storage and attach the volumes to the worker nodes. Enabled by default                         |  `true` | Yes      |
| `storage_capacity`         |  Sets the capacity of the volume in GBs. |   `200`    | Yes      |
| `resource_group_name`        | The resource group name where the cluster is housed|         | Yes      |
| `dc_region` | The region that resources will be provisioned in. Ex: "us-east" "us-south" etc.                                                                                                                 |         | Yes      |
| `cluster_name`      | The name of the cluster created |  | Yes       |
| `portworx_service_name`      | The name of the portworx-service |  | Yes       |
| `storage_region`    | The region the storage should be installed in. This should be under the same as `dc-region`. Ex: "us-east-1" "us-south-1" etc.  |  | yes       |
| `plan` | This plan has two options for installing portworx: `"px-dr-enterprise", "px-enterprise"`. | `"px-enterprise"` | Yes       |
| `px_tags`    | Portworx tags, make sure to add just the cluster name. Ex: `["cluster-name"]`  |  | Yes       |
| `kvdb`     | KVDB allows `internal` or `external`  | `internal` | yes       |
| `secret_type`     | The secret_type refers to where the secret hould be located. Available options are `k8s` or `ibm-kp`. | `k8s` | yes       |

**NOTE** The boolean input variable `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.

For an example of how to put all this together, refer to our [Cloud Pak for Multi Cloud Management Terraform script](https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform/cp4mcm).


## Executing the Terraform Script

Run the following commands to execute the TF script (containing the modules to create/use ROKS and Portworx). Execution may take about 5-15 minutes:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Clean up

To clean up or remove Portworx and Storage from a cluster, execute the following commands:

**Note**: You must login to the cluster in your terminal to successfully run the commands.
```bash
curl -fsL https://install.portworx.com/px-wipe | bash 
helm delete –purge portworx

./scripts/remove_storage.sh -c $CLUSTER_NAME

terraform destroy
```





