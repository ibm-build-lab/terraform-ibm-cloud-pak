# Terraform Module to install Cloud Pak for Network Automation

### NOTE: This module has been deprecated and is no longer supported.


This Terraform Module installs **Cloud Pak for Network Automation** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4na`

## Provisioning this module in a Terraform Script

**NOTE:** an OpenShift cluster with at least 5 nodes of size 16x64 is required to install this module. This can be an existing cluster or can be provisioned using our [roks](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/roks) Terraform module.


### Provisioning the CP4NA Module

Use a `module` block assigning the `source` parameter to the location of this module. Then set the required [inputs](#input-variables).

```hcl
module "cp4na" {
  source = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4na"
  enable = true

  // ROKS cluster parameters:
  cluster_config_path = var.cluster_condig_path

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email
}
```

For an example on how to provision and execute this module go [here](./example).


## Inputs

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `enable`                           | If set to `false` does not install the cloud pak on the given cluster. By default it's enabled                                                                                                                        | `true`                      | No       |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |                             | Yes      
