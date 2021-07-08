# Terraform Module to Create an OpenShift Cluster on IBM Cloud

This Terraform Module creates an Openshift (ROKS) cluster on IBM Cloud Classic or VPC Gen 2 infrastructure.

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/roks`

- [Terraform Module to Create an OpenShift Cluster on IBM Cloud](#terraform-module-to-create-an-openshift-cluster-on-ibm-cloud)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Building a new ROKS cluster](#building-a-new-roks-cluster)
  - [Input Variables](#input-variables)
  - [Testing](#testing)
  - [Executing the module](#executing-the-module)
  - [Output Variables](#output-variables)
  - [Accessing the cluster](#accessing-the-cluster)
  - [Clean up](#clean-up)

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../../CREDENTIALS.md) for details.

## Building a new ROKS cluster

In your Terraform script define the `ibm` provisioner block with the `region`. 

```hcl
provider "ibm" {
  region     = "us-south"
}
```

Add a `module` block to provision the [roks](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/roks) module. Set `source` to `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks`. Then pass the input parameters depending on the infrastructure to deploy the cluster:

- **IBM Cloud Classic**

  ```hcl
  module "cluster" {
    source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks"

    // General variables:
    on_vpc         = false
    project_name   = "roks"
    owner          = "anonymous"
    environment    = "test"
    // Cloud Pak entitlement used for OCP license
    entitlement    = "cloud_pak" 

    // Openshift parameters:
    resource_group       = "default"
    roks_version         = "4.6"
    force_delete_storage = true

    // IBM Cloud Classic variables:
    datacenter          = "dal10"
    workers_count       = [1]
    flavors             = ["b3c.4x16"]
  }
  ```

- **IBM Cloud VPC Gen 2**

  ```hcl
  module "cluster" {
    source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks"

    // General variables:
    on_vpc         = "true"
    project_name   = "roks"
    owner          = "anonymous"
    environment    = "test"
    // OCP license will need to be added for entitlement
    entitlement    = "" 

    // Openshift parameters:
    resource_group       = "default"
    roks_version         = "4.6"
    force_delete_storage = true

    // IBM Cloud VPC variables:
    // Single zone
    vpc_zone_names = ["us-south-1"]
    flavors        = ["mx2.4x32"]
    workers_count  = [2]
    // Multizone
    //vpc_zone_names = ["us-south-1", "us-south-2", "us-south-3"]
    //flavors        = ["mx2.4x32","mx2.4x32","mx2.4x32"]
    //workers_count  = [2,2,2]
  }
  ```

## Input Variables

The Terraform script requires the following list of input variables. Here are some instructions to set their values for Terraform and how to get their values from IBM Cloud.

| Name | Description  | Default | Required |
| - | - | - | - |
| `enable`               | If set to `false` does not provision the Openshift cluster. Enabled by default  | `true`           | No       | | `on_vpc`               | If `true` provision the cluster on IBM Cloud VPC Gen 2, otherwise provision on IBM Cloud Classic                                                                   | `true`           | No       |
| `project_name`         | Used to name the cluster with the environment name, like this: `{project_name}-{environment}-cluster`<br />It's also used to label the cluster and other resources  |  | Yes      |
| `owner`                | User name or team name. Used to label the cluster and other resources   |  | Yes      |
| `environment`          | Used to name the cluster with the project name, like this: `{project_name}-{environment}-cluster` | `dev`            | No       |
| `entitlement`          | Source of OCP entitlement | `cloud_pak`            | No       |
| `resource_group`       | Resource Group used to host the cluster. List all available resource groups with: `ibmcloud resource groups`                                                                           | `default`        | No       |
| `roks_version`         | OpenShift version to install. List all available versions: `ibmcloud ks versions`. There is no need to include the suffix `_OpenShift`. The module will append it to install the specified version of OpenShift.  | `4.6`            | No       |
| `datacenter`           | **IBM Cloud Classic** only (`on_vpc` = `false`). This is the Datacenter or Zone in the Region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`    | `dal10`          | No       |
| `private_vlan_number`  | **IBM Cloud Classic** only. (`on_vpc` = `false`). Private VLAN assigned to your zone. Make it an empty string to select a private unnamed VLAN or to create new VLAN if there isn't one (i.e. this is the first cluster in the zone). To list available VLANs in the zone: `ibmcloud ks vlan ls --zone <datacenter>`. Make sure the the VLAN type is `private` and the router begins with `bc`. Use the `ID` or `Number` |                  | No       |
| `public_vlan_number`   | **IBM Cloud Classic** only (`on_vpc` = `false`). Public VLAN assigned to your zone. Set to an empty string to select a public unnamed VLAN or to create a new VLAN if there aren't any (i.e. this is the first cluster in the zone). List available VLANs in the zone: `ibmcloud ks vlan ls --zone <datacenter>`. Make sure the the VLAN type is `public` and the router begins with `fc`. Use the `ID` or `Number`    |                  | No       |
| `vpc_zone_names`       | **IBM Cloud VPC Gen 2** only (`on_vpc` = `true`). Array with the sub-zones in the region to create the workers groups. List all the zones with: `ibmcloud ks zone ls --provider vpc-gen2`. Example: `["us-south-1", "us-south-2", "us-south-3"]`   | `["us-south-1"]` | No       |
| `flavors`              | Array with the flavors or machine types of each of the workers.  List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2` or `ibmcloud ks flavors --zone dal10 --provider classic`. On Classic it is only possible to have one worker group, so only list one flavor, i.e. `["b3c.16x64"]`. Example on VPC `["mx2.4x32", "mx2.8x64", "cx2.4x8"]` or `["mx2.4x32"]`  | `["mx2.4x32"]`   | No       |
| `workers_count`        | Array with the amount of workers on each workers group. On Classic it's only possible to have one workers group, so only the first number in the list is taken for the cluster size. Example: `[1, 3, 5]` or `[2]`   | `[2]`            | No       |
| `force_delete_storage` | If set to `true`, force the removal of persistent storage associated with the cluster during cluster deletion. Default value is `false`.                                                             | `false`          | No       |

## Testing

To manually run a module test before committing the code:

- go to the `testing` subdirectory
- follow instructions [here](testing/README.md)

The testing code provides an example of how to use the module.

## Executing the module

After setting all the input parameters, execute the following commands to create the cluster (may take about 30 minutes):

```bash
terraform init
terraform plan
terraform apply
```

## Output Variables

The module returns the following output variables:

| Name       | Description                                             |
| ---------- | ------------------------------------------------------- |
| `endpoint` | The URL of the public service endpoint for your cluster |
| `id`       | The unique identifier of the cluster.                   |
| `name`     | The name of the cluster                                 |

## Accessing the cluster

If you use the cluster from other terraform code there may be no need to download the kubeconfig file. However, if you plan to use the cluster from the CLI (i.e. `kubectl`) or other application then it's recommended to download it to some directory.

After execution has completed, access the cluster using `kubectl` or `oc`:

```bash
ibmcloud ks cluster config -cluster $(terraform output cluster_id)
kubectl cluster-info
```

## Clean up

When you finish using the cluster, you can release the resources by executing the following command, it should finish in about _8 minutes_:

```bash
terraform destroy
```
