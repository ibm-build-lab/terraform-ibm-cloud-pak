
# Example to provision LDAP Terraform Module

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md).
Set required values in a `terraform.tfvars` file.  Here are some examples:

```bash
ibmcloud_api_key      = "*******************"
iaas_classic_api_key  = "*******************"
iaas_classic_username = "******"
region                = "dal10"
os_reference_code     = "CentOS_8_64"
datacenter            = "*****"
hostname              = "ldapvm"
ibmcloud_domain       = "<my company>.cloud" 
cores                 = "2"
memory                = "4096"
disks                 = [25]
```

These parameters are:

- `ibmcloud_api_key`        : IBM Cloud API key (See https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)
- `iaas_classic_api_key`    : IBM Classic Infrastucture API Key (see https://cloud.ibm.com/docs/account?topic=account-classic_keys)
- `iaas_classic_username`   : IBM Classic Infrastucture User Name (see https://cloud.ibm.com/docs/schematics?topic=schematics-create-tf-config)
- `region`                  : Region code (https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions)
- `os_reference_code`       : The Operating System Reference Code, for example `CentOS_8_64` (see https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform)
- `datacenter`              : The datacenter to which the Virtual Machine will be deployed to, for example dal10. (see https://cloud.ibm.com/docs/schematics?topic=schematics-create-tf-config)
- `hostname`                : Hostname of the virtual Server.
- `ibmcloud_domain`         : Domain of the Cloud Account.
- `cores`                   : Virtual Server CPU Cores.
- `memory`                  : Virtual Server Memory
- `disks`                   : Boot disk size

### Execute the example

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

Verify the output "ibm_compute_vm_instance.cp4baldap (remote-exec): Start LDAP complete" is displayed and a Public IP created after the process is complete.

CLASSIC_IP_ADDRESS = "***.**.***.***"

Note: The LDAP server should not be exposed in the Public interface using port 389. Configure the appropriate Security Groups required for the Server.

A public and private key is created to access the Virtual Machine:

- generated_key_rsa
- generated_key_rsa.piub

use ssh to access the server provding the key files

```bash
ssh root@<CLASSIC_IP_ADDRESS> -k generated_key_rsa
```

Apache Directory Studio can be used to access the server (see https://directory.apache.org/studio/download/download-macosx.html)

### Cleanup

When the test is complete, execute: `terraform destroy`.


