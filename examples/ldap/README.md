
# Example to provision LDAP Terraform Module

1. Download required license files from [IBM Internal Software Download](https://w3-03.ibm.com/software/xl/download/ticket.wss) or [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/) into the  `../../modules/ldap/files` folder

    ```console
    DB2:
    Part Number : CNB21ML
    Filename : DB2_AWSE_Restricted_Activation_11.1.zip

    IBM SDS:
    Part Number : CRV3IML
    Filename : sds64-premium-feature-act-pkg.zip
    ```

 2. Update the ldif file

    Update the `../../modules/files/cp.ldif` file as needed to change the Directory Structure and user information.  For information on LDIF format, go [here](https://www.ibm.com/docs/en/i/7.4?topic=reference-ldap-data-interchange-format-ldif)

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md).

Set required values in a `terraform.tfvars` file.  Here are some examples:

```bash
ibmcloud_api_key      = "*******************"
iaas_classic_api_key  = "*******************"
iaas_classic_username = "******"
region                = "us-south"
os_reference_code     = "CentOS_8_64"
datacenter            = "dal12"
hostname              = "ldapvm"
ibmcloud_domain       = "ibm.cloud" 
cores                 = 2
memory                = 4096
disks                 = [25]
hourly_billing        = true
local_disk            = true
private_network_only  = false
ldapBindDN            = "cn=root"
ldapBindDNPassword    = "Passw0rd"
```

These parameters are:

- `ibmcloud_api_key`        : IBM Cloud API key (See https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)
- `iaas_classic_api_key`    : IBM Classic Infrastucture API Key (see https://cloud.ibm.com/docs/account?topic=account-classic_keys)
- `iaas_classic_username`   : IBM Classic Infrastucture User Name (see https://cloud.ibm.com/docs/schematics?topic=schematics-create-tf-config). To see your account user name, run the command `"ibmcloud sl user list"`
- `region`                  : Region code (https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions)
- `os_reference_code`       : The Operating System Reference Code, for example `CentOS_8_64` (see https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform)
- `datacenter`              : The datacenter to which the Virtual Machine will be deployed to, for example `dal10`. (see https://cloud.ibm.com/docs/schematics?topic=schematics-create-tf-config)
- `hostname`                : Hostname of the virtual Server
- `ibmcloud_domain`         : Domain of the Cloud Account
- `cores`                   : Virtual Server CPU Cores
- `memory`                  : Virtual Server Memory
- `disks`                   : Boot disk size
- `hourly_billing`          : The billing type for the instance. When set to `true`, the computing instance is billed on hourly usage. Otherwise, the instance is billed monthly.
- `local_disk`              : The disk type for the instance. When set to true, the disks for the computing instance are provisioned on the host that the instance runs. Otherwise, SAN disks are provisioned.
- `private_network_only`    : When set to `true`, a compute instance has only access to the private network.
- `ldapBindDN`              : LDAP Bind DN
- `ldapBindDNPassword`      : LDAP Bind DN password

## Execute the example

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

## Outputs

Verify the output "ibm_compute_vm_instance.cp4baldap (remote-exec): Start LDAP complete" is displayed and a Public IP created after the process is complete.

| Name                 | Description                                                                                                                                |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `ldap_id` | ID for the LDAP server |
| `ldap_ip_address` | IP address for LDAP server. Note: The LDAP server should not be exposed in the Public interface using port 389. Configure the appropriate Security Groups required for the Server. For more information on how to manage Security Groups visit : https://cloud.ibm.com/docs/security-groups?topic=security-groups-managing-sg |
| `ldapBindDN` | Bind DN (https://cloud.ibm.com/docs/discovery-data?topic=discovery-data-connector-ldap-cp4d) |
| `ldapBindDNPassword` | Bind DN Password (https://cloud.ibm.com/docs/discovery-data?topic=discovery-data-connector-ldap-cp4d) |

## To access the Virtual Machine

A public and private key is created to access the Virtual Machine:

```console
generated_key_rsa
generated_key_rsa.pub
```

use `ssh` to access the server providing the key files.

```bash
ssh root@<ldap_ip_address> -k generated_key_rsa
```

For more information on accessing the Virtual Machine, visit (https://cloud.ibm.com/docs/account?topic=account-mngclassicinfra)

For more information on accessing the Virtual Machine, visit (https://cloud.ibm.com/docs/account?topic=account-mngclassicinfra)

Apache Directory Studio can be used to access the server (see https://directory.apache.org/studio/download/download-macosx.html)

## Cleanup

When the project is complete, execute: `terraform destroy`.


