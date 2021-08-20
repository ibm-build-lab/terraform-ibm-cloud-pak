# Terraform Module to provision a Classic Virtual Server Instance and installs and configures IBM Secure Directory Server

This Terraform Module to provision a Classic Virtual Server Instance and installs and configures IBM Secure Directory Server

**Module Source**: `git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/ldap`

- [Terraform Module to install and configure IBM Secure Directory Server](#Terraform-Module-to-provision-a-Classic-Virtual-Server-Instance-and-installs-and-configures-IBM-Secure-Directory-Server)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Provisioning this module in a Terraform Script](#provisioning-this-module-in-a-terraform-script)
    - [Download required license files](#Download-required-license-files)
    - [Update the ldif file](#update-the-ldif-file)
  - [Input Variables](#input-variables)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Clean up](#clean-up)

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../../CREDENTIALS.md) for details.

## Provisioning this module in a Terraform Script

In your Terraform code define the `ibm` provisioner block with the `region`.

```hcl
provider "ibm" {
  region     = "us-south"
}
```

### Download required license files

Download the following DB2 and IBM SDS license files:

DB2:
PartUmber : CNB21ML
Filename : DB2_AWSE_Restricted_Activation_11.1.zip

IBM SDS:
PartUmber : CRV3IML
Filename : sds64-premium-feature-act-pkg.zip

Copy the files to the ./files folder

### Update the ldif file

Update the ldif file as needed to change the Directory Struture and user information

Update the /files/cp.ldif.

## Input Variables

| Name                    | Description                                                                                                                                                                                                 | Default | Required |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `enable`                | If set to `false` does not install IBM Secure Directory Server. Enabled by default                                                                                                                          | `true`  | No       |
| `ibmcloud_api_key`      | IBM Cloud API key (See https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)                                                                                                         |         | Yes      |
| `iaas_classic_api_key`  | IBM Classic Infrastucture API Key (see https://cloud.ibm.com/docs/account?topic=account-classic_keys)                                                                                                       |         | Yes      |
| `iaas_classic_username` | The IBM Cloud Classic Infrastructure username associated with the Classic Infrasture                                                                                                                        |         | Yes      |
| `region`                | Region code (https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions)                                                                                                                                |         | Yes      |
| `os_reference_code`     | The Operating System Reference Code, for example CentOS_8_64 (see https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform)                                                                              |         | Yes      |
| `datacenter`            | IBM Cloud data center in which you want to provision the instance.                                                                                                                                          |         | Yes      |
| `hostname`              | Hostname of the virtual Server                                                                                                                                                                              |         | Yes      |
| `ibmcloud_domain`       | IBM Cloud account Domain, example <My Company>.cloud                                                                                                                                                        |         | Yes      |
| `cores`                 | Virtual Server CPU Cores                                                                                                                                                                                    |         | Yes      |
| `memory`                | Virtual Server Memory                                                                                                                                                                                       |         | Yes      |
| `disks`                 | The numeric disk sizes in GBs for the instance's block device and disk image settings.                                                                                                                      |         | Yes      |
| `network_speed`         | The connection speed (in Mbps) for the instance's network components. The default value is 100                                                                                                              | `100`   | Yes      |
| `hourly_billing`        | The billing type for the instance. When set to true, the computing instance is billed on hourly usage. Otherwise, the instance is billed monthly. The default value is true.                                | `true`  | Yes      |
| `private_network_only`  | When set to true, a compute instance has only access to the private network. The default value is false.                                                                                                    | `false` | Yes      |
| `local_disk`            | The disk type for the instance. When set to true, the disks for the computing instance are provisioned on the host that the instance runs. Otherwise, SAN disks are provisioned. The default value is true. | `true`  | Yes      |
| `datacenter`            | IBM Cloud data center in which you want to provision the instance.                                                                                                                                          |         | Yes      |

### Executing the Terraform Script

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## outputs

Verify the output "ibm_compute_vm_instance.cp4baldap (remote-exec): Start LDAP complete" is displayed and a Public IP created after the process is complete.

| Name                 | Description                                                                                                                                |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `CLASSIC_IP_ADDRESS` | Note: The LDAP server should not be exposed in the Public interface using port 389.                                                        |
|                      | Configure the appropriate Security Groups required for the Server.                                                                         |
|                      | For more infomration on how to manage Security Groups visit : https://cloud.ibm.com/docs/security-groups?topic=security-groups-managing-sg |

A public and private key is created to access the Virtual Machine

generated_key_rsa
generated_key_rsa.piub

use ssh to access the server provding the key files.

ssh root@<CLASSIC_IP_ADDRESS> -k generated_key_rsa

For more information on accessing the Virtual Machine, visit (https://cloud.ibm.com/docs/account?topic=account-mngclassicinfra)

Apache Directory Studio can be used to access the server (see https://directory.apache.org/studio/download/download-macosx.html)

### Clean up

When the test is complete, execute: `terraform destroy`.
