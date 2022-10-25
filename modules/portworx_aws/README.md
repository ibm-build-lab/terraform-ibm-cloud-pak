# Terraform Module to install Portworx on AWS

This Terraform Module installs the **Portworx Service** on an Openshift (ROKS) cluster on AWS.

**Module Source**: `github.com/ibm-build-labs/terraform-ibm-cloud-pak.git//modules/aws_portworx`

- [Terraform Module to install Portworx](#terraform-module-to-install-cloud-pak-for-multi-cloud-management)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Provisioning this module in a Terraform Script](#provisioning-this-module-in-a-terraform-script)
    - [Setting up the OpenShift cluster](#setting-up-the-openshift-cluster)
    - [Installing Portworx Module](#provisioning-the-portworx-module)
  - [Input Variables](#input-variables)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Clean up](#clean-up)

## Set up access to AWS

* Enable ROSA [here](https://console.aws.amazon.com/rosa/home)
* Get RedHat ROSA token [here](https://cloud.redhat.com/openshift/token/rosa)
* Fill out the `variables.tf` in the root folder (or create a `terraform.tfvars` file) for your variables using the VARIABLES.md as a reference
* Install `python`, `pip` and `aws` CLIs:
  * RHEL:
  ```bash
  yum install wget jq httpd-tools python36 -y
  ln -s /usr/bin/python3 /usr/bin/python; ln -s /usr/bin/pip3 /usr/bin/pip
  pip install awscli --upgrade --user
  pip install pyyaml
  ```

## Provisioning this module in a Terraform Script

In your Terraform code define the `aws` provisioner block with the `region`, `access_key`, and `secret_key`.

```hcl
provider "aws" {
  region     = var.region
  access_key = var.access_key_id
  secret_key = var.secret_access_key
}
```

### Setting up the OpenShift cluster

NOTE: an OpenShift cluster is required to install this Portworx service. This can be an existing cluster or can be provisioned in the Terraform script.

### Provisioning the Portworx Module

Use a `module` block assigning `source` to `github.com/ibm-build-labs/terraform-ibm-cloud-pak.git//modules/portworx`. Then set the [input variables](#input-variables) required to install the Portworx service.

```hcl
module "portworx" {
  source                = "github.com/ibm-build-labs/terraform-ibm-cloud-pak.git//modules/aws_portworx"
  region                = var.region
  aws_access_key_id     = var.access_key_id
  aws_secret_access_key = var.secret_access_key
  portworx_enterprise   = var.portworx_enterprise
  portworx_essentials   = var.portworx_essentials
}
```


## Input Variables

| Name                           | Description                                                                                                                                                                                                                | Default | Required |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `aws_access_key_id`            | AWS access key id for the account |  | Yes       |
| `aws_secret_access_key`        | AWS secret access key for the account |  | Yes       |
| `region`                       | The region that resources will be provisioned in. Ex: `"us-east-1"` |         | Yes      |
| `portworx_enterprise`          | See `PORTWORX-ENTERPRISE.md` on how to get the Cluster ID, User ID and OSB Endpoint | { <br /> enable = false <br /> cluster_id = "" <br /> user_id = "" <br />  osb_endpoint = "" <br />} | Yes       |
| `portworx_essentials`          | See `PORTWORX-ESSENTIALS.md` on how to get the Cluster ID, User ID and OSB Endpoint  | { <br /> enable = false <br /> cluster_id = "" <br /> user_id = "" <br />  osb_endpoint = "" <br />}| Yes       |
| `disk_size`                    | Disk size for each Portworx volume  | `200` | No       |
| `kvdb_disk_size`               | Disk size for kvdb volume  | `200` | No       |
| `px_enable_monitoring`         | Enable monitoring on PX  | `true` | No       |
| `px_enable_csi`                | Enable CSI on PX  | `true` | No       |


For an example of how to put all this together, refer to the `/testing` directory.


## Executing the Terraform Script

Run the following commands to execute the TF script (containing the modules to create/use ROKS and Portworx). Execution may take about 5-15 minutes:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Clean up

To remove Portworx and Storage from a cluster, execute the following command:

Run in the cluster:

    curl -fsL https://install.portworx.com/px-wipe | bash


```bash
terraform destroy
```


## Reference

This AWS Portworx module is referenced from https://github.com/IBM/cp4d-deployment/tree/master/managed-openshift/aws/terraform/portworx.