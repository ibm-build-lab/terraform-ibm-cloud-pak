# Terraform Module to Create an OpenShift Cluster on IBM Cloud

This Terraform Module creates an Openshift (ROKS) cluster on IBM Cloud Classic or VPC Gen 2 infrastructure.

**Module Source**: `git::https://github.com/ibm-pett/terraform-ibm-cloud-pak.git//roks`

- [Terraform Module to Create an OpenShift Cluster on IBM Cloud](#terraform-module-to-create-an-openshift-cluster-on-ibm-cloud)
  - [Use](#use)
    - [Enable or Disable the Module](#enable-or-disable-the-module)
  - [Input Variables](#input-variables)
  - [Output Parameters](#output-parameters)

## Use

In your Terraform code define the `ibm` provisioner block with the `region` and the `generation`, which is **1 for Classic** and **2 for VPC Gen 2**. Optionally you can define the IBM Cloud credentials parameters or (recommended) pass them in environment variables.

```hcl
provider "ibm" {
  generation = 1
  region     = "us-south"
}
```

Export the environment variables for the credentials like so:

```bash
# Credentials required only for IBM Cloud Classic
export IAAS_CLASSIC_USERNAME="< Your IBM Cloud Username/Email here >"
export IAAS_CLASSIC_API_KEY="< Your IBM Cloud Classic API Key here >"

# Credentials required for IBM Cloud VPC and Classic
export IC_API_KEY="< IBM Cloud API Key >"
```

Use the `module` resource pointing the `source` to the location of this module, either local (i.e. `../roks`) or remote (`git::https://github.com/ibm-pett/terraform-ibm-cloud-pak.git//roks`). Then pass the input parameters depending of the infrastructure to deploy the cluster: Classic or VPC

- ROKS on **IBM Cloud Classic**

```hcl
module "cluster" {
  source = "git::https://github.com/ibm-pett/terraform-ibm-cloud-pak.git//roks"

  // General variables:
  on_vpc         = false
  project_name   = "roks"
  owner          = "johandry"
  environment    = "test"
  resource_group = "default"
  roks_version   = "4.4"

  // Kubernetes Config variables:
  download_config = true
  config_dir      = "./.kube/config"
  config_admin    = false
  config_network  = false

  // IBM Cloud Classic variables:
  datacenter          = "dal10"
  workers_count       = [1]
  flavors             = ["b3c.4x16"]
}
```

- ROKS on **IBM Cloud VPC Gen 2**

```hcl
module "cluster" {
  source = "git::https://github.com/ibm-pett/terraform-ibm-cloud-pak.git//roks"

  // General variables:
  on_vpc         = true
  project_name   = "roks"
  owner          = "johandry"
  environment    = "test"
  resource_group = "default"
  roks_version   = "4.4"

  // Kubernetes Config variables:
  download_config = true
  config_dir      = "./.kube/config"
  config_admin    = false
  config_network  = false

  // IBM Cloud VPC variables:
  vpc_zone_names = ["us-south-1"]
  flavors        = ["mx2.4x32"]
  workers_count  = [2]
}
```

After setting all the input parameters execute the following commands to create the cluster

```bash
terraform init
terraform plan
terraform apply
```

After around _20 to 30 minutes_ you can configure `kubectl` or `oc` to access the cluster executing:

```bash
export KUBECONFIG=$(terraform output config_file_path)
# Or using ibmcloud
ibmcloud ks cluster config -cluster $(terraform output cluster_id)

kubectl cluster-info
```

When you finish using the cluster, you can release the resources executing the following command, it should finish in about _8 minutes_:

```bash
terraform destroy
```

### Enable or Disable the Module

In Terraform the block parameter `count` is used to define how many instances of the resource are needed, including zero, meaning the resource won't be created. The `count` parameter on `module` blocks is only available since Terraform version 0.13.

Using Terraform 0.12 the workaround is to use the boolean input parameter `enable` with default value `true`. If the `enable` parameter is set to `false` the Openshift cluster is not provisioned. Use the `enable` parameter only if using Terraform 0.12 or lower, this parameter may be deprecated when Terraform 0.12 is not longer supported.

## Input Variables

Besides the access credentials the Terraform script requires the following list of input parameters, here are some instructions to set their values for Terraform and how to get their values from IBM Cloud.

| Name                  | Description                                                                                                                                                                                                                                                                                                                                                                                                                      | Default          | Required |
| --------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- | -------- |
| `enable`              | If set to `false` does not provision the Openshift cluster. By default it's enabled                                                                                                                                                                                                                                                                                                                                              | `true`           | No       |
| `on_vpc`              | If `true` provision the cluster on IBM Cloud VPC Gen 2, otherwise provision on IBM Cloud Classic                                                                                                                                                                                                                                                                                                                                 | `true`           | No       |
| `project_name`        | The project name is used to name the cluster with the environment name. It's also used to label the cluster and other resources                                                                                                                                                                                                                                                                                                  |                  | Yes      |
| `owner`               | Use your user name or team name. The owner is used to label the cluster and other resources                                                                                                                                                                                                                                                                                                                                      |                  | Yes      |
| `environment`         | The environment name is used to name the cluster with the project name                                                                                                                                                                                                                                                                                                                                                           | `dev`            | No       |
| `resource_group`      | Resource Group in your account to host the cluster. List all available resource groups with: `ibmcloud resource groups`                                                                                                                                                                                                                                                                                                          | `default`        | No       |
| `roks_version`        | OpenShift version to install. List all available versions: `ibmcloud ks versions`, there is no need to include the suffix `_OpenShift` the module will append it to install only the specified version of OpenShift. Compare versions at: https://ibm.biz/iks-versions                                                                                                                                                           | `4.4`            | No       |
| `datacenter`          | On **IBM Cloud Classic** (`on_vpc` = `false`) this is the datacenter or Zone in the region to provision the cluster. List all available zones with: `ibmcloud ks zone ls --provider classic`                                                                                                                                                                                                                                     | `dal10`          | No       |
| `private_vlan_number` | On **IBM Cloud Classic** (`on_vpc` = `false`) this is the private VLAN assigned to your zone. Make it an empty string to select a private unnamed VLAN or a to create new VLAN if there isn't any (i.e. this is the first cluster in the zone). List available VLAN's in the zone: `ibmcloud ks vlan ls --zone <datacenter>`, make sure the the VLAN type is `private` and the router begins with `bc`. Use the `ID` or `Number` |                  | No       |
| `public_vlan_number`  | On **IBM Cloud Classic** (`on_vpc` = `false`) this is the public VLAN assigned to your zone. Make it an empty string to select a public unnamed VLAN or a to create new VLAN if there isn't any (i.e. this is the first cluster in the zone). List available VLAN's in the zone: `ibmcloud ks vlan ls --zone <datacenter>`, make sure the the VLAN type is `public` and the router begins with `fc`. Use the `ID` or `Number`    |                  | No       |
| `vpc_zone_names`      | On **IBM Cloud VPC Gen 2** (`on_vpc` = `true`) this is the array with the subzones in the region to create the workers groups. List all the zones with: `ibmcloud ks zone ls --provider vpc-gen2`. Example: `["us-south-1", "us-south-2", "us-south-3"]`                                                                                                                                                                         | `["us-south-1"]` | No       |
| `flavors`             | Array with the flavors or machine types of each the workers group. On Classic it's only possible to have one workers group, so only the first flavor in the list is taken. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2`. Example: `["mx2.4x32", "mx2.8x64", "cx2.4x8"]` or `["mx2.4x32"]`                                                                                    | `["mx2.4x32"]`   | No       |
| `workers_count`       | Array with the amount of workers on each workers group. On Classic it's only possible to have one workers group, so only the first number in the list is taken for the cluster size. Example: `[1, 3, 5]` or `[2]`                                                                                                                                                                                                               | `[2]`            | No       |
| `download_config`     | If `true` download the kubernetes configuration files and certificates to the directory that you specified in `config_dir`                                                                                                                                                                                                                                                                                                       | `false`          | No       |
| `config_dir`          | Directory on your local machine where you want to download the Kubernetes config files and certificates                                                                                                                                                                                                                                                                                                                          | `.`              | No       |
| `config_admin`        | If set to `true`, the Kubernetes configuration for cluster administrators is downloaded                                                                                                                                                                                                                                                                                                                                          | `false`          | No       |
| `config_network`      | If set to `true`, the Calico configuration file, TLS certificates, and permission files that are required to run `calicoctl` commands in your cluster are downloaded in addition to the configuration files for the administrator                                                                                                                                                                                                | `false`          | No       |

If you'll use the cluster from other terraform code there may be no need to download the kubeconfig file however, if you plan to use the cluster from the CLI (i.e. `kubectl`) or other application then it's recommended to download it to some directory.

## Output Parameters

The module return the following output parameters.

| Name                             | Description                                                                                             |
| -------------------------------- | ------------------------------------------------------------------------------------------------------- |
| `endpoint`                       | The URL of the public service endpoint for your cluster                                                 |
| `id`                             | The unique identifier of the cluster.                                                                   |
| `name`                           | The name of the cluster                                                                                 |
| `config`                         | Map type variable with the Kubernetes configuration. Includes the following parameters                  |
| `config.calico_config_file_path` | The path on your local machine where your Calico configuration files and certificates are downloaded to |
| `config.config_file_path`        | The path on your local machine where the cluster configuration file and certificates are downloaded to  |
| `config.id`                      | The unique identifier of the cluster configuration                                                      |
| `config.admin_key`               | The admin key of the cluster configuration. Note that this key is case sensitive                        |
| `config.admin_certificate`       | The admin certificate of the cluster configuration                                                      |
| `config.ca_certificate`          | The cluster CA certificate of the cluster configuration                                                 |
| `config.host`                    | The host name of the cluster configuration                                                              |
| `config.token`                   | The token of the cluster configuration                                                                  |
