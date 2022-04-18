# Terraform Module to install Openshift Data Foundation on a VPC cluster

This Terraform Module installs the **ODF Service** on an Openshift (ROKS) cluster on IBM Cloud.

A VPC cluster is required with at least three worker nodes. Each worker node must have a minimum of 16 CPUs and 64 GB RAM. https://cloud.ibm.com/docs/openshift?topic=openshift-deploy-odf-vpc for more information.

**Module Source**: `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/odf`

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../CREDENTIALS.md) for details.

You also need to install the [IBM Cloud cli](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli) as well as the [OpenShift cli](https://cloud.ibm.com/docs/openshift?topic=openshift-openshift-cli)

Make sure you have the latest updates for all IBM Cloud plugins by running `ibmcloud plugin update`.  

**NOTE**: These requirements are not required if running this Terraform code within an **IBM Cloud Schematics** workspace. They are automatically set from your account.

## Provisioning this module in a Terraform Script

NOTE: an OpenShift cluster is required to install this ODF service. This can be an existing cluster or can be provisioned in the Terraform script.

To provision a new cluster, refer [here](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/roks#building-a-new-roks-cluster) for the code to add to your Terraform script.

### Provisioning the ODF Module

Use a `module` block assigning `source` to `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/odf`. Then set the [input variables](#input-variables) required to install the ODF service.

```hcl
provider "ibm" {
}

// Module:
module "odf" {
  source = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/odf"
  is_enable = var.is_enable
  cluster = var.cluster
  ibmcloud_api_key = var.ibmcloud_api_key
}
```

## Input Variables

| Name                           | Description                                                                                                                                                                                                                | Default | Required |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `is_enable`                       | If set to `false` does not install OpenShift Data Foundation on the given cluster. Enabled by default | `true`  | No       |
| `ibmcloud_api_key`             | This requires an ibmcloud api key found here: `https://cloud.ibm.com/iam/apikeys`    |         | Yes       |
| `cluster`                   | The id of the OpenShift cluster to be installed on |  | Yes       |

**NOTE** The boolean input variable `is_enable` is used to enable/disable the module. 

## Output Variable

| Name                           | Description                                                                                                                                                                                                                | 
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `odf_is_ready`                       | Flag set when ODF has completed its install.  Used when adding this with other modules |

For an example of how to put all this together, refer to our [OpenShift Data Foundation Terraform Example](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/examples/odf).


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



