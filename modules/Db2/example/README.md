
# Example to provision DB2 Terraform Module

## Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](../Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md). 

Resources Required
-   1 worker node
-   Cores: 5.7 (2 for the Db2 engine and 3.7 for Db2 auxiliary services)
-   Memory: 10.4 GiB (4 GiB for the Db2 engine and 6.4 GiB for Db2 auxiliary services)

Set the desired values in the `terraform.tfvars` file

```hcl
ibmcloud_api_key             = "************"
resource_group               = "db2-rg"
region                       = "us-south"
cluster_id                   = "************"
cluster_config_path          = "./.kube/config"
enable_db2                   = true
entitled_registry_key        = "************"
entitled_registry_user_email = "************"
db2_instance_version         = "11.5.7.0-cn5"
operatorVersion              = "db2u-operator.v2.0.0"
db2_name                     = "mydb"
operatorChannel              = "v2.0"
db2_rwx_storage_class        = "ocs-storagecluster-cephfs"
db2_rwo_storage_class        = "ibmc-vpc-block-10iops-tier"
``` 

### Input Variables

| Name                       | Description                                                            | Default                | Required |
| ---------------------------|------------------------------------------------------------------------|------------------------|----------|
| `ibmcloud_api_key`         | IBM Cloud API key: https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key                                                    |                        | Yes      |
| `resource_group`           | Region where the cluster is created. Managing resource groups: https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui | `cloud-pak-sandbox` | Yes      |
| `region`                   | Region code: https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions                                                            | `us-south`             | No       |
| `cluster_id`               | Add cluster id to install the Cloud Pak on.   |          |   No   |
| `cluster_config_path`      | Directory to store the kubeconfig file, set the value to empty string to not download the config. If running in Schematics, use `/tmp/.schematics/.kube/config`  | `./.kube/config`        |   No     |
| `enable_db2`               | If set to `false`, IBM DB2 will not be installed. Enabled by default   |  `true`                |   No     |
| `db2_project_name`         | The namespace or project for Db2                                       | `ibm-db2`              |   No    |
| `db2_name`                 | The name of your Database.                                             | `sample-db2`           | No      |
| `db2_admin_username`       | Db2 default admin username                                              | `db2inst1`             |   No    |
| `db2_admin_user_password`  | Db2 admin password                          |                        |   Yes    |
| `db2_standard_license_key` | The standard license key for the Db2 database product. **Note**: The license key is required only for an Advanced DB2 installation.|                       |   No    |
| `operatorVersion`          | The version of the Db2 Operator. [Db2 Operators and their Associated Db2 Engines](https://www.ibm.com/docs/en/db2/11.5?topic=deployments-db2-red-hat-openshift)  |`db2u-operator.v1.1.11` |   Yes    |
| `operatorChannel`          | The Operator Channel performs rollout update when new release is available.|   `v1.1`           |   No    |
| `db2_instance_version`     | The version of the logical environment for Db2 Database Manager        |`11.5.6.0`              |   No     |
| `db2_cpu`                  | CPU setting for the pod requests and limits                            |   `16`                 |   No    |
| `db2_memory`               | Memory setting for the pod requests and limits                         |  `16Gi`               |   No    |
| `db2_storage_size`         | Storage size for the db2 databases                                     |  `150Gi`               |   No    |
| `db2_rwx_storage_class`        | Name for the RWX Storage Class                                             | `ibmc-file-gold-gid`   |   No     |
| `db2_rwo_storage_class`        | Name for the RWO Storage Class                                             | `ibmc-block-gold`   |   No     |
| `entitled_registry_key`    | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`| IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key. i.e: joe@ibm.com |              | Yes      |

### Execute the Terraform Script

Execute the following Terraform commands from this directory:

```bash
terraform init
terraform plan
terraform apply --auto-approve
```

### Outputs

The Terraform code return the following output parameters:

| Name                   | Description                                                                                 |
|------------------------|---------------------------------------------------------------------------------------------|
| `db2_host_address`     | Host name for DB2 instance                                                                  |
| `db2_ports`            | Port number for DB2 instance  
## Verify

If DB2 is successful and the process is completed, you should see the following similar outputs:

```console
Apply complete! Resources: 2 added, 0 changed, 2 destroyed.

Outputs:

db2_host_address =  @@@@@@@@@@@@-clust-c0b572361ba41c9eef42d4d51297b04b-0000.us-south.containers.appdomain.cloud                 
db2_ports =  00000,
 00001,
```

## Clean up

When you finish with Db2, release the resources by executing the following command:
```
terraform destroy
```
Additional resources are creating using scripts. The cleanup process for these additional resources is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successful re-installation.
