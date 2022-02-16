
# Terraform Module to install and configure DB2 on Openshift

**Module Source**: `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/Db2`

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../../CREDENTIALS.md) for details.

### Download required license files

Download required license files from [IBM Internal Software Download](https://w3-03.ibm.com/software/xl/download/ticket.wss) or [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/) into the  `./files` folder

```console
DB2:
Part Number : CNB21ML
Filename : DB2_AWSE_Restricted_Activation_11.5.zip

Note: the license key is required only for Advanced DB2 installation



## Provisioning this module in a Terraform Script

See the example [here](../../examples/Db2) on how to provision this module.

## Input Variables

| Name                      | Description                                                                                                                                                                                     | Default | Required |
| -----------------------    | -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------| ------- | -------- |
| `enable`                   | If set to `false` does not install IBM DB2. Enabled by default                                                                                                                                 | `true`  | No       |
| `db2_project_name`         |                                       |         | Yes      |
| `db2_admin_user_password`  |                                        |         | Yes      |
| `db2_standard_license_key` |                                        |         | Yes      |
| `operatorVersion`          |                                        |         | Yes      |
| `operatorChannel`          |                                   |         | Yes      |
| `db2_instance_version`     |                                  |    "11.5.6.0"     | No      |
| `db2_cpu`                  |                        |         | Yes      |
| `db2_memory`               |                     |         | Yes      |
| `db2_storage_size`         |                     |          | Yes      |
| `db2_storage_class`        |                     | ``   | No      |

### Executing the Terraform Script

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

### Verify

If DB2is successful, you should see

```console


```

displayed after the process is complete.

## Outputs

| Name                 | Description    |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ |
| `DB2 Host Name`      |     |
| `DB2 Port`      |     |



### Clean up

When the project is complete, execute: `terraform destroy`.
