# Terraform DB2 Module to install and configure DB2 on Openshift

## NOTE: This module has been deprecated and is no longer supported.

This Terraform Module installs **DB2** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/Db2`

**NOTE:** an OpenShift cluster is required to install this module. This can be an existing cluster or can be provisioned using our [roks](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/roks) Terraform module.

The recommended size for an OpenShift cluster on IBM Cloud Classic contains `4` workers of flavor `b3c.16x64`, however read the [Db2 installation methods](https://www.ibm.com/docs/en/db2/11.1?topic=servers-db2-installation-methods) to confirm these parameters or if you are using IBM Cloud VPC or a different OpenShift version.

## Resources Required
-   1 worker node
-   Cores: 5.7 (2 for the Db2 engine and 3.7 for Db2 auxiliary services)
-   Memory: 10.4 GiB (4 GiB for the Db2 engine and 6.4 GiB for Db2 auxiliary services)

## Download required license file

Download required license file from [IBM Internal Software Download](https://w3-03.ibm.com/software/xl/download/ticket.wss) or [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/) into the  `./files` folder on your local computer.

```bash
DB2:
Part Number : CNB21ML
Filename    : DB2_AWSE_Restricted_Activation_11.5.zip
```

## Provisioning and executing this module

Use a `module` block assigning the `source` parameter to the location of this module. Then set the required [input variables](#inputs).

```hcl
module "Db2" {
  source     = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/Db2"
  enable_db2 = var.enable_db2

  # ----- Cluster -----
  cluster_config_path      = data.ibm_container_cluster_config.cluster_config.config_file_path
  db2_project_name         = var.db2_project_name
  db2_name                 = var.db2_name
  db2_admin_username       = var.db2_admin_username
  db2_admin_user_password  = var.db2_admin_user_password
  db2_standard_license_key = var.db2_standard_license_key
  operatorVersion          = var.operatorVersion
  operatorChannel          = var.operatorChannel
  db2_instance_version     = var.db2_instance_version
  db2_cpu                  = var.db2_cpu
  db2_memory               = var.db2_memory
  db2_storage_size         = var.db2_storage_size
  db2_storage_class        = var.db2_storage_class
  entitled_registry_user_email = var.entitled_registry_user_email
  entitled_registry_key    = var.entitled_registry_key
}
```

For an example on how to provision and execute this module go [here](./example).

## Inputs

| Name                       | Description                                                            | Default                | Required |
| ---------------------------|------------------------------------------------------------------------|------------------------|----------|
| `ibmcloud_api_key`         | IBM Cloud API key: https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key                                                    |                        | Yes      |
| `resource_group`           | Region where the cluster is created. Managing resource groups: https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui | `Default` | Yes      |
| `region`                   | Region code: https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions                                                            | `us-south`             | No       |
| `cluster_config_path`      | Directory to store the kubeconfig file, set the value to empty string to not download the config. If running in Schematics, use `/tmp/.schematics/.kube/config`  | `./.kube/config`       |   No     |
| `enable_db2`               | If set to `false`, IBM DB2 will not be installed. Enabled by default   |  `true`                |   No     |
| `db2_project_name`         | The namespace or project for Db2                                       | `ibm-db2`              |   Yes    |
| `db2_name`                 | The name of your Database.                                             | `MYDB01`           | Yes      |
| `db2_admin_username`       | Db2 default admin username                                             | `db2inst1`             |   Yes    |
| `db2_admin_user_password`  | Db2 admin username defined in associated LDAP                          |                        |   Yes    |
| `db2_standard_license_key` | The standard license key for the Db2 database product. **Note**: The license key is required only for an Advanced DB2 installation.|                       |   No    |
| `operatorVersion`          | The version of the Db2 Operator. [Db2 Operators and their Associated Db2 Engines](https://www.ibm.com/docs/en/db2/11.5?topic=deployments-db2-red-hat-openshift) |`db2u-operator.v2.0.0` |   Yes    |
| `operatorChannel`          | The Operator Channel performs rollout update when new release is available.|   `v2.0`           |   Yes    |
| `db2_instance_version`     | The version of the logical environment for Db2 Database Manager        |`11.5.7.0-cn5`              |   No     |
| `db2_cpu`                  | CPU setting for the pod requests and limits                            |   `4`                 |   Yes    |
| `db2_memory`               | Memory setting for the pod requests and limits                         |  `16Gi`                |   Yes    |
| `db2_storage_size`         | Storage size for the db2 databases                                     |  `100Gi`               |   Yes    |
| `db2_rwx_storage_class`        | Name for the RWX Storage Class                                             | `ibmc-file-gold-gid`   |   No     |
| `db2_rwo_storage_class`        | Name for the RWO Storage Class                                             | `ibmc-block-gold`   |   No     |
| `entitled_registry_key`    | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`| IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key. i.e: joe@ibm.com |              | Yes      |


### Verify

If DB2 is successful and the process is completed, you should see the following similar outputs:
```
Apply complete! Resources: 2 added, 0 changed, 2 destroyed.

Outputs:

db2_host_address =  @@@@@@@@@@@@-clust-c0b572361ba41c9eef42d4d51297b04b-0000.us-south.containers.appdomain.cloud                 
db2_ports =  00000,
 00001,
db2_ip_address = xxx.xx.xx.xx
db2_pod_name = c-db2ucluster-db2u-0
```

## Outputs

The Terraform code return the following output parameters:

| Name                   | Description                                                                                 |
|------------------------|---------------------------------------------------------------------------------------------|
| `db2_host_address`     | Host url for DB2 instance                                                                  |
| `db2_ports`            | Port number for DB2 instance                                                                |
| `db2_ip_address`       | External IP address to reach DB2 service                                                       |
| `db2_pod_name`         | Db2 pod for deploying Db2 schemas                                                           |


