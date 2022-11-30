
# Example to provision LDAP Terraform Module

## Clone the repo

```bash
git clone https://github.com/ibm-build-lab/terraform-ibm-cloud-pak
```

## Download required license files 

Download the files from [IBM Internal Software Download](https://w3-03.ibm.com/software/xl/download/ticket.wss) or [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/) into the `terraform-ibm-cloud-pak/modules/ldap/files` folder.

```console
DB2:
Part Number : CNB21ML
Filename : DB2_AWSE_Restricted_Activation_11.1.zip

IBM SDS:
Part Number : CRV3IML
Filename : sds64-premium-feature-act-pkg.zip
```

## Update the ldif file

Update the `terraform-ibm-cloud-pak/modules/ldap/files/cp.ldif` file as needed to change the Directory Structure and user information.  For information on LDIF format, go [here](https://www.ibm.com/docs/en/i/7.4?topic=reference-ldap-data-interchange-format-ldif)

## Execute the example

### Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/blob/main/Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

### Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/blob/main/Using_Terraform.md). 

For local execution:
- cd into the `terraform-ibm-cloud-pak/modules/ldap/example` directory

- Set required values in a `terraform.tfvars` file.  Here are some examples:

  ```bash
  ibmcloud_api_key      = "*******************"
  iaas_classic_api_key  = "*******************"
  iaas_classic_username = "******"
  region                = "us-south"
  os_reference_code     = "CentOS_7_64"
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

- Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

## Inputs


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
  
## Outputs

Verify that the message: "ibm_compute_vm_instance.cp4ba ldap (remote-exec): Start LDAP complete" is displayed and a Public IP created after the process is complete.

| Name                 | Description                                                                                                                                |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `ldap_id` | ID for the LDAP server |
| `ldap_ip_address` | IP address for LDAP server. Note: The LDAP server should not be exposed in the Public interface using port 389. Configure the appropriate Security Groups required for the Server. For more information on how to manage Security Groups visit : https://cloud.ibm.com/docs/security-groups?topic=security-groups-managing-sg |
| `ldapBindDN` | Bind DN (https://cloud.ibm.com/docs/discovery-data?topic=discovery-data-connector-ldap-cp4d) |
| `ldapBindDNPassword` | Bind DN Password (https://cloud.ibm.com/docs/discovery-data?topic=discovery-data-connector-ldap-cp4d) |

### 5. Access the Virtual Machine

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

### 6. Cleanup

When the project is complete, execute: `terraform destroy`.


