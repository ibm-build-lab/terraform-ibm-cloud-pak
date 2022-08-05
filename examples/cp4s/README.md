# Example to provision CP4S Terraform Module

This example provisions an IBM Cloud Platform Classic Infrastructure OpenShift Cluster and installs the Cloud Pak for Security on it.  To install Cloud Pak for Security, a cluster is needed with at least 5 nodes of size 16x32.

NOTE:
An LDAP is required for new instances of CP4S.  This is not required for installation but will be required before CP4S can be used.  If you do not have an LDAP you can complete the installation however full features will not be available until after LDAP configuration is complete.  There is terraform automation available to provision and LDAP [here](https://github.com/ibm-build-labs/terraform-ibm-cloud-pak/tree/main/examples/ldap). This link can provide more information [here](https://www.ibm.com/docs/en/cloud-paks/cp-security/1.8?topic=providers-configuring-ldap-authentication).  

## Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](../Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md). 

Set the desired values in the `terraform.tfvars` file:

```hcl
source          = "./.."

// ROKS cluster parameters:
cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
region = var.region
resource_group_name = var.resource_group_name
cluster_id = var.cluster_id

// Entitled Registry parameters:
entitled_registry_key        = var.entitled_registry_key
entitled_registry_user_email = var.entitled_registry_user_email

admin_user = var.admin_user
```

These parameters are:


- `cluster_config_path`: Path leading to the cluster info by default is set to ./.kube/config/ . For schematics, use `/tmp/.schematics/.kube/config`
- `region`: Region that the cluster is located in.
- `entitled_registry_key`: Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key
- `entitled_registry_user_email`: IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key
- `admin_user`: The admin user name that will be used with the LDAP.  Refer to the CP4S documentation on LDAP requirments

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

One of the Test Scenarios is to verify the YAML files rendered to install IAF, these files are generated in the directory `rendered_files`. Go to this directory to validate that they are generated correctly.

### Cleanup

 execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf test.auto.tfvars terraform.tfstate* .terraform .kube rendered_files` as well as delete the `cp4s_cli_install` and `ibm-cp-security`

