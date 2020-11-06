# Terraform Module to install Cloud Pak for Applications

This Terraform Module install **Applications Cloud Pak** on an existing Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4app`

- [Terraform Module to install Cloud Pak for Applications](#terraform-module-to-install-cloud-pak-for-applications)
  - [Use](#use)
    - [Building a ROKS cluster](#building-a-roks-cluster)
    - [Using an existing ROKS cluster](#using-an-existing-roks-cluster)
    - [Enable or Disable the Module](#enable-or-disable-the-module)
    - [Using the cp4app Module](#using-the-cp4app-module)
  - [Input Variables](#input-variables)
  - [Output Variables](#output-variables)

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

_Running this Terraform code from IBM Cloud Schematics don't require to set these parameters, they are set automatically from your account by IBM Cloud Schematics._

Before using the Cloud Pak for Applications module it's required to have an OpenShift cluster, this could be an existing cluster or you can provision it in your code using the ROKS module.

### Building a ROKS cluster

To build the cluster in your code, use the ROKS module, pointing it with `source` to the location of this module (`git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks`). Then pass the input parameters with the cluster specification required to run CP4App.

```hcl
module "cluster" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//roks"
  ...
}
```

<!-- TODO: Add a link to the App requirements from the IBM documentation -->

**IMPORTANT**: The output parameters of the ROKS module are used as input parameters for the cp4app module however, if this fails do not pass the parameters directly from the module, instead use the data resource `ibm_container_cluster_config` to get the cluster configuration and pass it to the module.

### Using an existing ROKS cluster

To use an existing OpenShift cluster, add a code similar the following to get the cluster configuration:

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

The variable `cluster_name_id` can have either the cluster name or ID. The resource group where the cluster is running is also required, for this one use the data resource `ibm_resource_group`.

The output parameters of the cluster configuration data resource `ibm_container_cluster_config` are used as input parameters for the Applications Cloud Pak module.

### Enable or Disable the Module

In Terraform the block parameter `count` is used to define how many instances of the resource are needed, including zero, meaning the resource won't be created. The `count` parameter on `module` blocks is only available since Terraform version 0.13.

Using Terraform 0.12 the workaround is to use the boolean input parameter `enable` with default value `true`. If the `enable` parameter is set to `false` the Cloud Pak for App is not installed. Use the `enable` parameter only if using Terraform 0.12 or lower, this parameter may be deprecated when Terraform 0.12 is not longer supported.

### Using the cp4app Module

Use the `module` block assigning the `source` parameter to the location of this module, either local (i.e. `../cp4app`) or remote (`git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4app`). Then pass the input parameters required to install Cloud Pak for Applications.

```hcl
module "cp4app" {
  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4app"
  enable = true

  entitled_registry_key        = file("${path.cwd}/entitlement.key")
  entitled_registry_user_email = var.entitled_registry_user_email
  cluster_config_path          = data.ibm_container_cluster_config.cluster_config.config_file_path
  cp4app_installer_command     = var.cp4app_installer_command
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

To clean up or remove cp4app and its dependencies from a cluster, assign `uninstall` to the `cp4app_installer_command` variable and execute `terraform apply`.

**Note**: The uninstall/cleanup up process is a work in progress at this time, we are identifying the objects that needs to be deleted in order to have a successfully re-installation. This process will be included in the Terraform code.

When you finish using the cluster, you can release the resources executing the following command, it should finish in about _8 minutes_:

```bash
terraform destroy
```

## Input Variables

| Name                           | Description                                                                                                                                                                                                                | Default   | Required |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | -------- |
| `enable`                       | If set to `false` does not install Cloud-Pak for Applications on the given cluster. By default it's enabled                                                                                                                | `true`    | No       |
| `openshift_version`            | Openshift version installed in the cluster                                                                                                                                                                                 |           | Yes      |
| `cluster_config_path`          | The path on your local machine where the cluster configuration file and certificates are downloaded to                                                                                                                     |           | Yes      |
| `entitled_registry_key`        | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |           | Yes      |
| `entitled_registry_user_email` | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |           | Yes      |
| `cp4app_installer_command`     | Command to execute by the icpa installer, the most common are: `install`, `uninstall`, `check`, `upgrade`                                                                                                                  | `install` | No       |

## Output Variables

Once the Terraform code finish use the following output variables to access Applications Cloud Pak Dashboards:

| Name                    | Description                                                |
| ----------------------- | ---------------------------------------------------------- |
| `endpoint`              | URL of the cp4app dashboard                                |
| `advisor_ui_endpoint`   | URL of the Advisor UI dashboard                            |
| `navigator_ui_endpoint` | URL of the Navigator UI dashboard                          |
| `installer_namespace`   | Kubernetes namespace where the icpa installer is installed |
