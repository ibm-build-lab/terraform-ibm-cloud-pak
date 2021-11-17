
# Terraform Module to install and configure IBM Secure Directory Server on a Classic Virtual Server Instance

**Module Source**: `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git/modules/ldap`

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../../CREDENTIALS.md) for details.

### Download required license files

Download required license files from [IBM Internal Software Download](https://w3-03.ibm.com/software/xl/download/ticket.wss) or [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/) into the  `./files` folder

```console
DB2:
Part Number : CNB21ML
Filename : DB2_AWSE_Restricted_Activation_11.1.zip

IBM SDS:
Part Number : CRV3IML
Filename : sds64-premium-feature-act-pkg.zip
```

### Update the ldif file

Update the `./files/cp.ldif` file as needed to change the Directory Struture and user information. For information on LDIF format, go [here](https://www.ibm.com/docs/en/i/7.4?topic=reference-ldap-data-interchange-format-ldif)

## Provisioning this module in a Terraform Script

See the example [here](../../examples/ldap) on how to provision this module.

## Input Variables

| Name                    | Description                                                                                                                                                                                                 | Default | Required |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `enable`                | If set to `false` does not install IBM Secure Directory Server. Enabled by default  | `true`  | No       |
| `ibmcloud_api_key`      | IBM Cloud API key (See https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key). Needed to create SSH Key                                                   |         | Yes      |
| `iaas_classic_api_key`  | IBM Classic Infrastucture API Key (see https://cloud.ibm.com/docs/account?topic=account-classic_keys). Needed to create SSH key                                               |         | Yes      |
| `iaas_classic_username` | The IBM Cloud Classic Infrastructure username associated with the Classic Infrasture API key. Needed to create SSH key                                                      |         | Yes      |
| `region`                | Region code (https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions) |         | Yes      |
| `os_reference_code`     | The Operating System Reference Code, for example `CentOS_8_64` (see https://cloud.ibm.com/docs/ibm-cloud-provider-for-terraform)    |         | Yes      |
| `datacenter`            | IBM Cloud data center in which you want to provision the instance.    |         | Yes      |
| `hostname`              | Hostname of the virtual Server    |    "ldapvm"     | No      |
| `ibmcloud_domain`       | IBM Cloud account Domain, example `<My Company>.cloud`    |    ibm.cloud     | Yes      |
| `cores`                 | Virtual Server CPU Cores    |         | Yes      |
| `memory`                | Virtual Server Memory    |         | Yes      |
| `disks`                 | Array of numeric disk sizes in GBs for the instance's block device and disk image settings. Example: `[25]` or `[25, 10, 20]`  |          | Yes      |
| `network_speed`         | The connection speed (in Mbps) for the instance's network components. The default value is `100`   | `100`   | No      |
| `hourly_billing`        | The billing type for the instance. When set to `true`, the computing instance is billed on hourly usage. Otherwise, the instance is billed monthly. The default value is `true`.                                | `true`  | No      |
| `private_network_only`  | When set to `true`, a compute instance has only access to the private network. The default value is `false`.    | `false` | No      |
| `local_disk`            | The disk type for the instance. When set to `true`, the disks for the computing instance are provisioned on the host that the instance runs. Otherwise, SAN disks are provisioned. The default value is `true`. | `true`  | No      |
| `ldapBindDN`            | LDAP Bind DN (https://cloud.ibm.com/docs/discovery-data?topic=discovery-data-connector-ldap-cp4d)     | `true`  | Yes      |
| `ldapBindDNPassword`    | LDAP Bind DN password (https://cloud.ibm.com/docs/discovery-data?topic=discovery-data-connector-ldap-cp4d)      |         | Yes      |

### Executing the Terraform Script

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

### Verify

If LDAP is successful, you should see

```console
ibm_compute_vm_instance.cp4baldap (remote-exec): Start LDAP complete
CLASSIC_IP_ADDRESS = "***.**.***.***"
```

displayed after the process is complete.

## Outputs

| Name                 | Description    |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `CLASSIC_IP_ADDRESS` | Note: The LDAP server should not be exposed in the Public interface using port 389. Configure the appropriate Security Groups required for the Server. For more information on how to manage Security Groups visit : https://cloud.ibm.com/docs/security-groups?topic=security-groups-managing-sg |

A public and private key are created locally to access the Virtual Machine

```console
generated_key_rsa
generated_key_rsa.pub
```

use ssh to access the server providing the key files.

```console
ssh root@<CLASSIC_IP_ADDRESS> -k generated_key_rsa
```

For more information on accessing the Virtual Machine, visit (https://cloud.ibm.com/docs/account?topic=account-mngclassicinfra)

Apache Directory Studio can be used to access the server (see https://directory.apache.org/studio/download/download-macosx.html)

### Clean up

When the project is complete, execute: `terraform destroy`.
