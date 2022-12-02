# Terraform Module to install Cloud Pak for Security

This Terraform Module installs **Cloud Pak for Security Operator** on an Openshift (ROKS) cluster on IBM Cloud. Once the Terraform module has run a cluster will install the CP4S operator creating the threat management resource.  After the threat management resource is created further configuration will be needed, you can follow the instructions on the CP4S documentation [here](https://www.ibm.com/docs/en/cloud-paks/cp-security/1.10?topic=security-postinstallation)

**Module Source**: `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4s`

## Provisioning this module in a Terraform Script

**NOTE:** an OpenShift cluster is required to install this module. This can be an existing cluster or can be provisioned using our [roks](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/roks) Terraform module.

The recommended size for an OpenShift 4.6+ cluster on IBM Cloud Classic contains `5` workers of flavor `b3c.8x32`, however read the [Cloud Pak for Security documentation](https://www.ibm.com/docs/en/cloud-paks/cp-security/1.6.0?topic=requirements-hardware).

An LDAP is required for new instances of CP4S.  This is not required for installation but will be required before CP4S can be used.  If you do not have an LDAP you can complete the installation however full features will not be available until after LDAP configuration is complete.  This link can provide more information [here](https://www.ibm.com/docs/en/cloud-paks/cp-security/1.8?topic=providers-configuring-ldap-authentication).  There is terraform automation available to provision and LDAP [here](https://github.com/ibm-build-labs/terraform-ibm-cloud-pak/tree/main/modules/ldap/example).


### Provisioning the CP4S Module

Use a `module` block assigning the `source` parameter to the location of this module. Then set the required [input variables](#inputs).

```hcl
module "cp4s" {
  source          = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4s"
  enable          = true

  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email
  admin_user                   = var.admin_user
}
```

## Inputs

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
 `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |                             | Yes      |
| `admin_user`                           | The user name of the LDAP that cp4s will use on default configuration                                                                                                                        |                       | Yes       |

For an example on how to provision and execute this module go [here](./example).
