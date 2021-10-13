# Terraform Module to install Cloud Pak for Security

This Terraform Module installs **Cloud Pak for Security** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4s`

- [Terraform Module to install Cloud Pak for Security](#terraform-module-to-install-cloud-pak-for-security)
  - [Required command line tools](#prerequisites)
    - [LDAP](#ldap)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Provisioning this module in a Terraform Script](#provisioning-this-module-in-a-terraform-script)
    - [Setting up the OpenShift cluster](#setting-up-the-openshift-cluster)
    - [Using the CP4S Module](#using-the-cp4s-module)
  - [Input Variables](#input-variables)
    - [Sample Input](#sample-input)
  - [Executing the Terraform Script](#executing-the-terraform-script)

## Prerequisites

The cloud pak for security installer runs on your machine, for the installer go [here](https://www.ibm.com/docs/en/cloud-paks/cp-security/1.6.0?topic=tasks-installing-developer-tools) to be sure your command line tools are compatible.

### LDAP

Cloud Pak for Security requires a functioning LDAP to create instances.  This means that while the install can be completed without the LDAP, Cloud Pak for Security will require the configuration of one before using its features.  If you do not have an LDAP you can use [this](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/ldap) terraform module to create one.

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../../CREDENTIALS.md) for details.

## Provisioning this module in a Terraform Script

### Setting up the OpenShift cluster

NOTE: an OpenShift cluster is required to install the Cloud Pak. This can be an existing cluster or can be provisioned using our `roks` Terraform module. An LDAP is required for functinoality but not for installation. You can set up a LDAP on your own or use our `ldap` Terrform module then get the admin user name for the script.

If you do not have an LDAP you can complete the installation however full features will not be available until after LDAP configuration is complete.

To provision a new cluster, refer [here](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/roks) for the code to add to your Terraform script. The recommended size for an OpenShift 4.6+ cluster on IBM Cloud Classic contains `5` workers of flavor `b3c.8x32`, however read the [Cloud Pak for Security documentation](https://www.ibm.com/docs/en/cloud-paks/cp-security/1.6.0?topic=requirements-hardware) .

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

- `ldap_status`: true for a configured LDAP and user name, false otherwise

- `ldap_user_id`: value of ldap admin uid

Output:

`ibm_container_cluster_config` used as input for the `cp4s` module

### Using the CP4S Module

Use a `module` block assigning the `source` parameter to the location of this module `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4s`. Then set the [input variables](#input-variables) required to install the Cloud Pak for Security.

```hcl
source          = "./.."

// ROKS cluster parameters:
cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path

// Prereqs
worker_node_flavor = var.worker_node_flavor

// Entitled Registry parameters:
entitled_registry_key        = var.entitled_registry_key
entitled_registry_user_email = var.entitled_registry_user_email

// LDAP

ldap_status = var.ldap_status
ldap_user_uid = var.ldap_user_id
```

## Input Variables

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |                             | Yes      |
| `ldap_status`                           | Set to true if ldap is available for configuration                                                                                                                        |                       | Yes       |
| `ldap_user_id`                           | LDAP admin user uid                                                                                                                        |                       | Yes       |

**NOTE** The boolean input variable `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.

For an example of how to put all this together, refer to our [Cloud Pak for Security Terraform script](https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform//cp4s).

### Sample Input

Instead of inputing the variables you can pass a test.auto.tfvars file.  The layout of the file will look like this below.

```bash

// Resource/Data Req to get cluster info
region              = "<region>"
resource_group_name = "<resource_group_name>"
cluster_config_path    = "./kube/config"
cluster_id          = "<cluster id>"
// CP4aiops Module Req
enable          = true
// Entitled Registry parameters:
entitled_registry_key        = "<entitlment key>"
entitled_registry_user_email = "<email>"

ldap_status = false
ldap_user_id = "<ldap user>"

```

## Executing the Terraform Script

Execute the following commands to install the Cloud Pak:

```bash
terraform init
terraform plan
terraform apply
```
