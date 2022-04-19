# Example to provision Cloud Pak for Business Automation Terraform Module

## Prereq

This Cloud Pak example depends on having a DB2 instance with the CP4BA Schema set up.  See https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/examples/Db2 to create a DB2 instance.  See https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/blob/cp4ba-db-schema/examples/cp4ba/database/README.md to set up the CP4BA Schema.

## Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](../Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md). 

### Set the desired values in the terraform.tfvars file

```hcl
ibmcloud_api_key             = "************"
resource_group               = "************"
region                       = "************"
cluster_id                   = "************"
cluster_config_path          = "************"
ldap_admin_name              = "cn=root"
ldap_admin_password          = "Passw0rd"
ldap_host_ip                 = "xx.xx.xxx.xxx"
enable_db2                   = "************"
db2_project_name             = "************"
db2_user                     = "db2inst1"
db2_admin_username           = "************"
db2_admin_user_password      = "************"
db2_host_address             = "************"
db2_port_number              = "12345"
enable_cp4ba                 = true
cp4ba_project_name           = "*************"
entitled_registry_key        = "************"
entitled_registry_user_email = "************"
```

### Input Variables

| Name                       | Description                                                            | Default                | Required |
| ---------------------------|------------------------------------------------------------------------|------------------------|----------|
| `ibmcloud_api_key`         | IBM Cloud API key: https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key                                                    |                        | Yes      |
| `resource_group`           | Region where the cluster is created. Managing resource groups: https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui | `cloud-pak-sandbox` | Yes      |
| `region`                   | Region code: https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions                                                            | `us-south`             | No       |
| `cluster_id`               | Add cluster id to install the Cloud Pak on.   |          |   No   |
| `cluster_config_path`      | Path to the cluster configuration file to access your cluster          | `./.kube/config`        |   No     |
| `ldap_admin`               | LDAP Admin user name | `cn=root`  | Yes      |
| `ldap_password`            | LDAP Admin password | `Passw0rd` | Yes      |
| `ldap_host_ip`             | LDAP server IP address |  | Yes      |
| `enable_db2`               | If set to `false`, IBM DB2 will not be installed. Enabled by default   |  `true`                |   No     |
| `db2_project_name`         | The namespace or project for Db2                                       | `ibm-db2`              |   Yes    |
| `db2_user `                | Db2 instance user name defined in LDAP.                                | `db2inst1`             |   Yes    |
| `db2_admin_username`       | Db2 default admin username                                             | `cpadmin`              |   Yes    |
| `db2_admin_user_password`  | Db2 admin username defined in associated LDAP                          |                        |   Yes    |
| `db2_host_address  `       | DB2 instance host name which will be used in ICP4ACluster to access the Db2. |                  |   No     |
| `db2_ports`                | Port number for DB2 instance                                                 |                  |   Yes    |
| `enable_cp4ba`             | It enables the installation of CP4BA. If set to false, CP4BA will not be installed. | `true`    |   No     |
| `cp4ba_project_name`       | The namespace or project for CP4BA                                     | `cp4ba`                |   Yes    |
| `entitled_registry_key`    | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`| IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key. i.e: joe@ibm.com |              | Yes      |


### Execute the example

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

### Verify

To verify installation on the Kubernetes cluster, go to the Openshift console and go to the `Installed Operators` tab. Choose your `namespace` and click on `IBM Cloud Pak for Business Automation. 
When run and complted successfully, Terraform will return the outputs as follow: 
```

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

cp4ba_admin_password = ********************************
cp4ba_admin_username = admin
cp4ba_endpoint =  j@@@@@@@@@@@@-clust-c0b572361ba41c9eef42d4d51297b04b-0000.us-south.containers.appdomain.cloud
```

### Outputs

The Terraform code return the following output parameters:

| Name                   | Description                                                                                 |
|------------------------|---------------------------------------------------------------------------------------------|
| `cp4ba_endpoint`       | Host name for CP4BA                                                                         |
| `cp4ba_admin_username` | CP4BA identification used to login in CP4BA online service.                                 |
| `cp4ba_admin_password` | A passcode that will allowed a user with an admin priviledge to gain admission to the CP4BA online service.|


## Clean up

When you finish with CP4BA, release the resources by executing the following command:: 
```
terraform destroy
```
Additional resources are creating using scripts. The cleanup process for these additional resources is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successful re-installation.
