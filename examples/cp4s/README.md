# Test CP4S Module

## 1. Set up access to IBM Cloud

If running this module from your local terminal, you need to set the credentials to access IBM Cloud.

You can define the IBM Cloud credentials in the IBM provider block but it is recommended to pass them in as environment variables.

Go [here](../../CREDENTIALS.md) for details.

## 2. Test

### Using Terraform client

Follow these instructions to test the Terraform Module manually

Create the file `test.auto.tfvars` with the following input variables, these values are fake examples:

```hcl
source          = "./.."
enable          = var.enable

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

These parameters are:

- `enable`: If set to `false` does not install the cloud pak on the given cluster. By default it's enabled
- `entitled_registry_key`: Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key
- `entitled_registry_user_email`: IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key
- `ldap_status` : True if you have an LDAP configured
- `ldap_user_id` : LDAP user admin uid
Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

One of the Test Scenarios is to verify the YAML files rendered to install IAF, these files are generated in the directory `rendered_files`. Go to this directory to validate that they are generated correctly.

## 3. Cleanup

 execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf test.auto.tfvars terraform.tfstate* .terraform .kube rendered_files` as well as delete the `cp4s_cli_install` and `ibm-cp-security`
