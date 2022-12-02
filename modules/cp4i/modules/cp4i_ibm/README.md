# Terraform Module to install Cloud Pak for Integration

This Terraform Module installs **Cloud Pak for Integration** version **2022.2** on an **Openshift (ROKS)** cluster **(4.10+)** on IBM Cloud. It follows the instructions located [here](https://www.ibm.com/docs/en/cloud-paks/cp-integration/2022.2?topic=installing-overview-installation).

**Module Source**: `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4i/modules/cp4i_ibm`

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../CREDENTIALS.md) for details.

## Provisioning this module in a Terraform Script

### Setting up the OpenShift cluster

**NOTE:** an OpenShift cluster is required to install the Cloud Pak. This can be an existing cluster or can be provisioned using Terraform modules. The current versions of the operators being installed require OpenShift version 4.10 or higher.

The recommended size for an OpenShift cluster on IBM Cloud Classic contains `4` workers of flavor `b3c.16x64`, however read the [Cloud Pak for Integration documentation](https://www.ibm.com/docs/en/cloud-paks/cp-integration) to confirm these parameters or if you are using IBM Cloud VPC or a different OpenShift version.

This code will provision an OpenShift cluster on classic infrastructure: 
```hcl

data "ibm_resource_group" "rg" {
  name = var.resource_group
}

module "classic-openshift-single-zone-cluster" {
  source = "terraform-ibm-modules/cluster/ibm//modules/classic-openshift-single-zone"

  // Openshift parameters:
  cluster_name          = "cp4i-dev"
  worker_zone           = "dal13"
  hardware              = "shared"
  resource_group_id     = data.ibm_resource_group.rg.id
  worker_nodes_per_zone = 4
  worker_pool_flavor    = "b3c.16x64"
  public_vlan           = <public vlan for resource group>
  private_vlan          = <private vlan for resource group>
  kube_version          = "4.10"
  tags                  = ["", "", ""]
  entitlement           = <cloud-pak-entitlement-key>
}
```
The following code retrieves the cluster (new or existing) configuration:

```hcl

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = "cp4i-dev"
  resource_group_id = data.ibm_resource_group.rg.id
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

To provision a new VPC cluster, refer [here](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/roks#building-a-new-roks-cluster) for the code to add to your Terraform script.

### Using the CP4I Module

Use a `module` block assigning the `source` parameter to the location of this module `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4i`. Then set the [input variables](#input-variables) required to install the Cloud Pak for Integration.

```hcl
module "cp4i" {
  source = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4i/modules/cp4i_ibm"
  enable = true

  // ROKS cluster parameters:
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  storageclass        = var.storageclass

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  namespace           = "cp4i"
}
```

An example of how provision and execute this module is located [here](../../examples/cp4i).

## Input Variables

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `enable`                           | If set to `false` does not install the cloud pak on the given cluster. By default it's enabled  | `true`                      | No       |
| `storageclass`                           | Storage class to use.  For Classic, use `ibmc-file-gold-gid`. For VPC, set to `portworx-rwx-gp3-sc` and make sure Portworx is set up on the cluster                                                | `ibmc-file-gold-gid`                      | No       |
| `namespace`                           | Namespace to install for Cloud Pak for Integration | `cp4i`                      | No       |
| `cluster_config_path`                           | Path to the Kubernetes configuration file to access your cluster | `./.kube/config`                      | No       |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key |                             | Yes      |

## Executing the Terraform Script

Execute the following commands to install the Cloud Pak:

```bash
terraform init
terraform plan
terraform apply
```

## Clean up

When you finish using the cluster, release the resources by executing the following command:

```bash
terraform destroy
```
