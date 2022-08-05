# Terraform Module to install Cloud Pak for Security

This Terraform Module installs **Cloud Pak for Security Operator** on an Openshift (ROKS) cluster on IBM Cloud. Once the Terraform module has run a cluster will install the CP4S operator creating the threat management resource.  After the threat management resource is created further configuration will be needed, you can follow the instructions on the CP4S documentation [here](https://www.ibm.com/docs/en/cloud-paks/cp-security/1.8?topic=security-postinstallation)

**Module Source**: `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4s`

- [Terraform Module to install Cloud Pak for Security](#terraform-module-to-install-cloud-pak-for-security)
  - [Required command line tools](#setup-tools)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Provisioning this module in a Terraform Script](#provisioning-this-module-in-a-terraform-script)
    - [Setting up the OpenShift cluster](#setting-up-the-openshift-cluster)
    - [Using the CP4S Module](#using-the-cp4s-module)
  - [Input Variables](#input-variables)
  - [Executing the Terraform Script](#executing-the-terraform-script)

## Setup Tools

The cloud pak for security installer runs on your machine, for the installer go [here](https://www.ibm.com/docs/en/cloud-paks/cp-security/1.6.0?topic=tasks-installing-developer-tools) to be sure your command line tools are compatible.

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../../CREDENTIALS.md) for details.

## Provisioning this module in a Terraform Script

### Setting up the OpenShift cluster

NOTE: An OpenShift cluster is required to install the Cloud Pak. This can be an existing cluster or can be provisioned using our `roks` Terraform module.

An LDAP is required for new instances of CP4S.  This is not required for installation but will be required before CP4S can be used.  If you do not have an LDAP you can complete the installation however full features will not be available until after LDAP configuration is complete.  This link can provide more information [here](https://www.ibm.com/docs/en/cloud-paks/cp-security/1.8?topic=providers-configuring-ldap-authentication).  There is terraform automation available to provision and LDAP [here](https://github.com/ibm-build-labs/terraform-ibm-cloud-pak/tree/main/examples/ldap).

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

Output:

`ibm_container_cluster_config` used as input for the `cp4s` module

### Using the CP4S Module

Use a `module` block assigning the `source` parameter to the location of this module `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4s`. Then set the [input variables](#input-variables) required to install the Cloud Pak for Security.

```hcl
module "cp4s" {
  source          = "github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/cp4s"
  enable          = true

  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email
  admin_user = var.admin_user
}
```

## Input Variables

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
 `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |                             | Yes      |
| `admin_user`                           | The user name of the LDAP that cp4s will use on default configuration                                                                                                                        |                       | Yes       |


For an example of how to put all this together, refer to our [Cloud Pak for Security Terraform script](https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform//cp4s).

## Executing the Terraform Script

Execute the following commands to install the Cloud Pak:

```bash
terraform init
terraform plan
terraform apply
```
