
# Terraform Module to install and configure DB2 on Openshift

**Module Source**: `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/Db2`

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../../CREDENTIALS.md) for details.

### Download required license files

Download required license files from [IBM Internal Software Download](https://w3-03.ibm.com/software/xl/download/ticket.wss) or [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/) into the  `./files` folder
```bash
DB2:
Part Number : CNB21ML
Filename    : DB2_AWSE_Restricted_Activation_11.5.zip
```
Note: the license key is required only for Advanced DB2 installation



## Provisioning this module in a Terraform Script

See the example [here](../../examples/Db2) on how to provision this module.

## Input Variables

| Name                       | Description                                                            | Default                | Required |
| ---------------------------|------------------------------------------------------------------------|------------------------|----------|
| `ibmcloud_api_key`         | IBM Cloud API key: https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key                                                    |                        | Yes      |
| `resource_group`           | Region where the cluster is created. Managing resource groups: https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui        | `default`              | Yes      |
| `region`                   | Region code: https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions                                                            | `us-south`             | No       |
| `enable_db2`               | If set to `false`, IBM DB2 will not be installed. Enabled by default   |  `true`                |   No     |
| `db2_project_name`         | The namespace or project for Db2                                       | `ibm-db2`              |   Yes    |
| `db2_admin_user_password`  | Db2 admin username defined in associated LDAP                             | `cpadmin`              |   Yes    |
| `db2_standard_license_key` | The standard license key for the Db2 database product                  |                        |   Yes    |
| `operatorVersion`          | The version of the Db2 Operator                                        |`db2u-operator.v1.1.10` |   Yes    |
| `operatorChannel`          | The Operator Channel performs rollout update when new release is available.|   `v1.1`           |   Yes    |
| `db2_instance_version`     | The version of the logical environment for Db2 Database Manager        |`11.5.6.0`              |   No     |
| `db2_cpu`                  | CPU setting for the pod requests and limits                            |   `16`                 |   Yes    |
| `db2_memory`               | Memory setting for the pod requests and limits                         |  `110Gi`               |   Yes    |
| `db2_storage_size`         | Storage size for the db2 databases                                     |  `200Gi`               |   Yes    |
| `db2_storage_class`        | Name for the Storage Class                                             | `ibmc-file-gold-gid`   |   No     |


### Executing the Terraform Script

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

### Verify

If DB2 is successful and the process is completed, you should see the following similar outputs:
```
```

## Outputs

| Name                 | Description                                                                                 |
| -------------------- |---------------------------------------------------------------------------------------------|
| `DB2 Host Name`      |                                                                                             |
| `DB2 Port`           |                                                                                             |



### Clean up

When the project is complete, execute: 
```
terraform destroy
```


## Uninstall

**Note**: The uninstall/cleanup process is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successful re-installation.
