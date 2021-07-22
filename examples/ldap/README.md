# Example to provision LDAP Terraform Module

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md)
Set the following values in the `terraform.tfvars` file:

```bash
ibmcloud_api_key      = "*******************"
iaas_classic_api_key  = "*******************"
iaas_classic_username = "******"
region                = "******"
domain                = "*******************"
os_reference_code     = "***********"
datacenter            = "*****"

```

These parameters are:

- `ibmcloud_api_key`: IBM Cloud API key (See https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)
- `iaas_classic_api_key`: IBM Classic Infrastucture API Key (see https://cloud.ibm.com/docs/account?topic=account-classic_keys)
- `domain`: Domain of the Cloud Account.
- `os_reference_code`: The Operating System Reference Code, for example CentOS_8_64 (see https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform)
- `datacenter`: The datacenter to which the Virtual Machine will be deployed to, for example dal10. (see https://cloud.ibm.com/docs/schematics?topic=schematics-create-tf-config)

Update the ldif file as needed to chnage the Directory Struture

### Execute the example

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

Verify the output "ibm_compute_vm_instance.cp4baldap (remote-exec): Start LDAP complete" is displayed and a Public IP created after the process is complete.

CLASSIC_IP_ADDRESS = "**\*.**.**_._**"

A public and private key is created to access the Virtual Machine

generated_key_rsa
generated_key_rsa.piub

use ssh to access the server provding the key files

ssh root@<CLASSIC_IP_ADDRESS> -k generated_key_rsa

Apache Directory Studio can be used to access the server (see https://directory.apache.org/studio/download/download-macosx.html)

### Cleanup

When the test is complete, execute: `terraform destroy`.
