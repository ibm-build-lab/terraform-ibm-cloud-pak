# Terraform Module to install Cloud Pak for Watson AIOps

This Terraform Module installs **Cloud Pak for Watson AIOps** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4aiops`

- [Terraform Module to install Cloud Pak for Watson AIOps](#terraform-module-to-install-cloud-pak-for-aiops)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Setting up the OpenShift cluster](#setting-up-the-openshift-cluster)
  - [Installing the CP4AIOps Module](#installing-the-cp4aiops-module)
  - [Input Variables](#input-variables)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Accessing the Cloud Pak Console](#accessing-the-cloud-pak-console)
  - [Post Installation Instructions](#post-installation-instructions)
  - [Clean up](#clean-up)
  - [Troubleshooting](#troubleshooting)
  
## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../CREDENTIALS.md) for details.


### Setting up the OpenShift cluster

NOTE: an OpenShift cluster is required to install the Cloud Pak. This can be an existing cluster or can be provisioned using our `roks` Terraform module.

To provision a new cluster, refer [here](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/roks) for the code to add to your Terraform script. The recommended size for an OpenShift 4.7+ cluster on IBM Cloud Classic contains `9` workers (3 for `AIManager` and 6 for `EventManager`) of flavor `b3c.16x64`.

However please read the following documentation:
- [Cloud Pak for Watson AIOps documentation (AIManager)](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.2.1?topic=requirements-ai-manager)
- [Cloud Pak for Watson AIOps documentation (EventManager)](https://www.ibm.com/docs/en/noi/1.6.3?topic=preparing-sizing)

To confirm these parameters or if you are using IBM Cloud VPC or a different OpenShift version.

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

`ibm_container_cluster_config` used as input for the `cp4aiops` module

### Installing the CP4AIOPS Module

Use a `module` block assigning `source` to `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4aiops`. Then set the [input variables](#input-variables) required to install the Cloud Pak for Watson AIOps.

```hcl
module "cp4aiops" {
  source    = "./.."
  enable    = true

  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc
  portworx_is_ready   = 1          // Assuming portworx is installed if using VPC infrastructure

  // Entitled Registry parameters:
  entitlement_key        = var.entitlement_key
  entitled_registry_user = var.entitled_registry_user

  // AIOps specific parameters:
  namespace            = var.namespace
  accept_aiops_license = var.accept_aiops_license
  enable_aimanager     = var.enable_aimanager
  enable_event_manager = var.enable_event_manager
}
```

- 

## Input Variables

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `enable`                           | If set to `false` does not install the cloud pak on the given cluster. By default it's enabled                                                                                                                        | `true`                      | No       |
| `on_vpc`                           | If set to `false`, it will set the install do classic ROKS. By default it's disabled                                                                                                                        | `false`                      | No       |
| `cluster_config_path`                | The path of the kube config                                                                                                                                                                                 | `4.7`                       | No       |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |                             | Yes      |
| `portworx_is_ready`          | Variable to catch the portworx module completion. Set to `1` if Portworx has already been installed or a classic installation. Otherwise set it to `0` |  | Yes       |
| `namespace`            | Name of the namespace aiops will be located   | `cp4aiops` | no       |
| `accept_aiops_license` | Do you accept the licensing agreements? `T/F` | `false`    | yes      |
| `enable_aimanager`     | Install AIManager? `T/F`                      | `true`     | no       |
| `enable_event_manager` | Install Event Manager? `T/F`                  | `true`     | no       |


**NOTE** The boolean input variable `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.

For an example of how to put all this together, refer to our [Cloud Pak for Watson AIOps Terraform script](https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform/cp4aiops).

## Executing the Terraform Script

Execute the following commands to install the Cloud Pak:

```bash
terraform init
terraform plan
terraform apply
```

## Accessing the Cloud Pak Console

After execution has completed, access the cluster using `kubectl` or `oc`:

```bash
ibmcloud oc cluster config -c <cluster-name> --admin
oc get route -n ${NAMESPACE} cpd -o jsonpath=‘{.spec.host}’ && echo
```

To get default login id:

```bash
oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 -d && echo
```

To get default Password:

```bash
oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d && echo
```

## Post Installation Instructions

This section is _REQUIRED_ if you install AIManager and EventManager. 

Please follow the documentation starting at `step 3` to `step 9` [here](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.2.1?topic=installing-ai-manager-event-manager) for further info.


## Clean up

When you finish using the cluster, release the resources by executing the following command:

```bash
terraform destroy
```
