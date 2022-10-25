# Terraform Module to install Openshift Data Foundation on a VPC cluster

This Terraform Module installs the **ODF Service** on an Openshift (ROKS) cluster on IBM Cloud.

A ROKS cluster is required with at least three worker nodes. Each worker node must have a minimum of 16 CPUs and 64 GB RAM. https://cloud.ibm.com/docs/openshift?topic=openshift-deploy-odf-vpc for more information.

**Module Source**: `github.com/ibm-build-labs/terraform-ibm-cloud-pak.git//modules/odf`

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../CREDENTIALS.md) for details.

You also need to install the [IBM Cloud cli](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli) as well as the [OpenShift cli](https://cloud.ibm.com/docs/openshift?topic=openshift-openshift-cli)

Make sure you have the latest updates for all IBM Cloud plugins by running `ibmcloud plugin update`.  

**NOTE**: These requirements are not required if running this Terraform code within an **IBM Cloud Schematics** workspace. They are automatically set from your account.

## Provisioning this module in a Terraform Script

NOTE: an OpenShift cluster is required to install this ODF service. This can be an existing cluster or can be provisioned in the Terraform script.

To provision a new cluster, refer [here](https://github.com/ibm-build-labs/terraform-ibm-cloud-pak/tree/main/modules/roks#building-a-new-roks-cluster) for the code to add to your Terraform script.

### Provisioning the ODF Module

Use a `module` block assigning `source` to `github.com/ibm-build-labs/terraform-ibm-cloud-pak.git//modules/odf`. Then set the [input variables](#input-variables) required to install the ODF service.

```hcl
provider "ibm" {
}

// Module:
module "odf" {
  source = "github.com/ibm-build-labs/terraform-ibm-cloud-pak.git//modules/odf"
  cluster = var.cluster
  ibmcloud_api_key = var.ibmcloud_api_key

  monSize = var.monSize
  monStorageClassName = var.monStorageClassName
  osdStorageClassName = var.osdStorageClassName
  osdSize = var.osdSize
  numOfOsd = var.numOfOsd
  billingType = var.billingType
  ocsUpgrade = var.ocsUpgrade
  clusterEncryption = var.clusterEncryption
}
```

## Input Variables

| Name                           | Description                                                                                                                                                                                                                | Default | Required |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `ibmcloud_api_key`             | This requires an ibmcloud api key found here: `https://cloud.ibm.com/iam/apikeys`    |         | Yes       |
| `cluster`                   | The id of the OpenShift cluster to be installed on |  | Yes       |
| `roks_version`                   | ROKS Cluster version (4.7 or higher) |  | Yes       |
| `osdStorageClassName`                   | Storage class that you want to use for your OSD devices | ibmc-vpc-block-10iops-tier | Yes       |
| `osdSize`                   | Size of your storage devices. The total storage capacity of your ODF cluster is equivalent to the osdSize x 3 divided by the numOfOsd | 100Gi | Yes       |
| `numOfOsd`                   | Number object storage daemons (OSDs) that you want to create. ODF creates three times the numOfOsd value | 1 | Yes       |
| `billingType`                   | Billing Type for your ODF deployment (`essentials` or `advanced`) | advanced | Yes       |
| `ocsUpgrade`                   | Whether to upgrade the major version of your ODF deployment | false | Yes       |
| `clusterEncryption`                   | Enable encryption of storage cluster | false | Yes       |
| `monSize`                   | Size of the storage devices that you want to provision for the monitor pods. The devices must be at least 20Gi each | 20Gi | Yes (Only roks 4.7)       |
| `monStorageClassName`                   | Storage class to use for your Monitor pods. For VPC clusters you must specify a block storage class | ibmc-vpc-block-10iops-tier | Yes (Only roks 4.7)       |

**NOTE** The boolean input variable `is_enable` is used to enable/disable the module. 

## Output Variable

| Name                           | Description                                                                                                                                                                                                                | 
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `odf_is_ready`                       | Flag set when ODF has completed its install.  Used when adding this with other modules |

For an example of how to put all this together, refer to our [OpenShift Data Foundation Terraform Example](https://github.com/ibm-build-labs/terraform-ibm-cloud-pak/tree/main/examples/odf).


## Executing the Terraform Script

Run the following commands to execute the TF script (containing the modules to create/use ROKS and ODF). Execution may take about 5-15 minutes:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Clean up

When the cluster is no longer needed, run `terraform destroy` if this was created using your local Terraform client with `terraform apply`. 

If this cluster was created using `schematics`, just delete the schematics workspace and specify to delete all created resources.

<b>For ODF:</b>

To uninstall ODF and its dependencies from a cluster, execute the following commands:

While logged into the cluster

```bash
terraform destroy -target null_resource.enable_odf
```
This will disable the ODF on the cluster

Once this completes, execute: `terraform destroy` if this was create locally using Terraform or remove the Schematic's workspace.



