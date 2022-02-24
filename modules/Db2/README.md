
# Terraform Module to install and configure DB2 on Openshift

**Module Source**: `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/Db2`

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../../CREDENTIALS.md) for details.

### Download required license files

Download required license files from [IBM Internal Software Download](https://w3-03.ibm.com/software/xl/download/ticket.wss) or [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/) into the  `../../modules/db2/files` folder
```bash
DB2:
Part Number : CNB21ML
Filename    : DB2_AWSE_Restricted_Activation_11.5.zip
```

## Provisioning this module in a Terraform Script

See the example [here](../../examples/Db2) on how to provision this module.

## Input Variables

| Name                       | Description                                                            | Default                | Required |
| ---------------------------|------------------------------------------------------------------------|------------------------|----------|
| `ibmcloud_api_key`         | IBM Cloud API key: https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key                                                    |                        | Yes      |
| `resource_group`           | Region where the cluster is created. Managing resource groups: https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui | `cloud-pak-sandbox` | Yes      |
| `region`                   | Region code: https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions                                                            | `us-south`             | No       |
| `cluster_config_path`      | Path to the cluster configuration file to access your cluster          | `/.kube/config`        |   No     |
| `enable_db2`               | If set to `false`, IBM DB2 will not be installed. Enabled by default   |  `true`                |   No     |
| `db2_project_name`         | The namespace or project for Db2                                       | `ibm-db2`              |   Yes    |
| `db2_admin_username`       | Db2 default admin username                                              | `db2inst1`             |   Yes    |
| `db2_admin_user_password`  | Db2 admin username defined in associated LDAP                          |                        |   Yes    |
| `db2_standard_license_key` | The standard license key for the Db2 database product. **Note**: The license key is required only for an Advanced DB2 installation.|                       |   No    |
| `operatorVersion`          | The version of the Db2 Operator                                        |`db2u-operator.v1.1.10` |   Yes    |
| `operatorChannel`          | The Operator Channel performs rollout update when new release is available.|   `v1.1`           |   Yes    |
| `db2_instance_version`     | The version of the logical environment for Db2 Database Manager        |`11.5.6.0`              |   No     |
| `db2_cpu`                  | CPU setting for the pod requests and limits                            |   `16`                 |   Yes    |
| `db2_memory`               | Memory setting for the pod requests and limits                         |  `16Gi`               |   Yes    |
| `db2_storage_size`         | Storage size for the db2 databases                                     |  `150Gi`               |   Yes    |
| `db2_storage_class`        | Name for the Storage Class                                             | `ibmc-file-gold-gid`   |   No     |
| `entitled_registry_key`    | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`| IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key. i.e: joe@ibm.com |              | Yes      |


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

## Output Parameters

The Terraform code return the following output parameters:

| Name                   | Description                                                                                 |
|------------------------|---------------------------------------------------------------------------------------------|
| `db2_host_address`     | Host name for DB2 instance                                                                  |
| `db2_ports`            | Port number for DB2 instance                                                                |



### Clean up

When you finish installing Db2, release the resources by executing the following command:: 
```
terraform destroy
```


## Uninstall

**Note**: The uninstall/cleanup process is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successful re-installation.
