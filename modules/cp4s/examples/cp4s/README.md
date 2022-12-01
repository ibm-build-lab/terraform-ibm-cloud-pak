# Example to provision CP4S Terraform Module

This example installs the Cloud Pak for Security on an IBM OpenShift cluster.

**NOTE:** an OpenShift cluster is required to install this module. This can be an existing cluster or can be provisioned using our [roks](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/roks) Terraform module. The recommended size for an OpenShift 4.6+ cluster on IBM Cloud Classic contains `5` workers of flavor `b3c.8x32`, however read the [Cloud Pak for Security documentation](https://www.ibm.com/docs/en/cloud-paks/cp-security/1.6.0?topic=requirements-hardware).

An LDAP is required for new instances of CP4S.  This is not required for installation but will be required before CP4S can be used.  If you do not have an LDAP you can complete the installation however full features will not be available until after LDAP configuration is complete. There is terraform automation available to provision an LDAP [here](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/examples/ldap). This link can provide more information [here](https://www.ibm.com/docs/en/cloud-paks/cp-security/1.8?topic=providers-configuring-ldap-authentication).  

## Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/blob/main/Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/blob/main/Using_Terraform.md). 

### Create a terraform.tfvars file

Set your desired values in the `terraform.tfvars` file:

```hcl
// ROKS cluster parameters:
region = "us-south"
resource_group_name = "my-rg"
cluster_id = "*********************"

// Entitled Registry parameters:
entitled_registry_key        = "****************************************"
entitled_registry_user_email = "johndoe@ibm.com"
admin_user = "admin"
```

These parameters are:

- `region`: Region that the cluster is located in.
- `entitled_registry_key`: Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key
- `entitled_registry_user_email`: IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key
- `admin_user`: The admin user name that will be used with the LDAP.  Refer to the CP4S documentation on LDAP requirments

### Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Cleanup

 execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf test.auto.tfvars terraform.tfstate* .terraform .kube rendered_files` as well as delete the `cp4s_cli_install` and `ibm-cp-security`

