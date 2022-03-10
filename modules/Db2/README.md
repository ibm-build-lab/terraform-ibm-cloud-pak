# Terraform DB2 Module toinstall and configure DB2 on Openshift

This Terraform Module installs **DB2** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/Db2`

- [Terraform DB2 Module toinstall and configure DB2 on Openshift](#terraform-db2-module-toinstall-and-configure-db2-on-openshift)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Download required license files](#download-required-license-files)
  - [Provisioning this module in a Terraform Script](#provisioning-this-module-in-a-terraform-script)
    - [Setting up the OpenShift cluster](#setting-up-the-openshift-cluster)
    - [Using the Db2 Module](#using-the-Db2-module)
  - [Input Variables](#input-variables)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Clean up](#clean-up)

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../CREDENTIALS.md) for details.

## Download required license files

Download required license files from [IBM Internal Software Download](https://w3-03.ibm.com/software/xl/download/ticket.wss) or [IBM Passport Advantage](https://www.ibm.com/software/passportadvantage/) into the  `../../modules/db2/files` folder on your local computer. 
```bash
DB2:
Part Number : CNB21ML
Filename    : DB2_AWSE_Restricted_Activation_11.5.zip
```

## Provisioning this module in a Terraform Script
In your Terraform script define the `ibm` provisioner block with the `version`.

```hcl
terraform {
  required_version = ">= 0.13"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.34"
    }
    null = {
      source = "hashicorp/null"
    }
  }
}

provider "ibm" {
  region           = var.region
  ibmcloud_api_key = var.ibmcloud_api_key
}
```

### Setting up the OpenShift cluster

NOTE: an OpenShift cluster is required to install the Cloud Pak. This can be an existing cluster or can be provisioned using our `roks` Terraform module.

To provision a new cluster, refer [here](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/modules/roks#building-a-new-roks-cluster) for the code to add to your Terraform script. The recommended size for an OpenShift cluster on IBM Cloud Classic contains `4` workers of flavor `b3c.16x64`, however read the [Db2 installation methods](https://www.ibm.com/docs/en/db2/11.1?topic=servers-db2-installation-methods) to confirm these parameters or if you are using IBM Cloud VPC or a different OpenShift version.

Add the following code to get the OpenShift cluster (new or existing) configuration:

```hcl
data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on        = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = true
  config_dir        = var.cluster_config_path
  admin             = false
  network           = false
}
```

**NOTE**: Create the `./kube/config` directory if it doesn't exist.

Input:

- `cluster_d`: either the cluster name or ID.

- `ibm_resource_group`:  resource group where the cluster is running

Output:

`ibm_container_cluster_config` used as input for the `Db2` module

### Using the DB2 Module

Use a `module` block assigning the `source` parameter to the location of this module `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/Db2`. Then set the [input variables](#input-variables) required to install Db2.

```hcl
module "Db2" {
  source     = "../../modules/Db2"
  enable_db2 = var.enable_db2

  # ----- Cluster -----
  cluster_config_path      = data.ibm_container_cluster_config.cluster_config.config_file_path
  db2_project_name         = var.db2_project_name
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

## Input Variables

| Name                       | Description                                                            | Default                | Required |
| ---------------------------|------------------------------------------------------------------------|------------------------|----------|
| `ibmcloud_api_key`         | IBM Cloud API key: https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key                                                    |                        | Yes      |
| `resource_group`           | Region where the cluster is created. Managing resource groups: https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui | `cloud-pak-sandbox` | Yes      |
| `region`                   | Region code: https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions                                                            | `us-south`             | No       |
| `cluster_config_path`      | Path to the cluster configuration file to access your cluster          | `./.kube/config`       |   No     |
| `enable_db2`               | If set to `false`, IBM DB2 will not be installed. Enabled by default   |  `true`                |   No     |
| `db2_project_name`         | The namespace or project for Db2                                       | `ibm-db2`              |   Yes    |
| `db2_admin_username`       | Db2 default admin username                                             | `db2inst1`             |   Yes    |
| `db2_admin_user_password`  | Db2 admin username defined in associated LDAP                          |                        |   Yes    |
| `db2_standard_license_key` | The standard license key for the Db2 database product. **Note**: The license key is required only for an Advanced DB2 installation.|                       |   No    |
| `operatorVersion`          | The version of the Db2 Operator. [Db2 Operators and their Associated Db2 Engines](https://www.ibm.com/docs/en/db2/11.5?topic=deployments-db2-red-hat-openshift) |`db2u-operator.v1.1.11` |   Yes    |
| `operatorChannel`          | The Operator Channel performs rollout update when new release is available.|   `v1.1`           |   Yes    |
| `db2_instance_version`     | The version of the logical environment for Db2 Database Manager        |`11.5.6.0`              |   No     |
| `db2_cpu`                  | CPU setting for the pod requests and limits                            |   `16`                 |   Yes    |
| `db2_memory`               | Memory setting for the pod requests and limits                         |  `16Gi`                |   Yes    |
| `db2_storage_size`         | Storage size for the db2 databases                                     |  `150Gi`               |   Yes    |
| `db2_storage_class`        | Name for the Storage Class                                             | `ibmc-file-gold-gid`   |   No     |
| `entitled_registry_key`    | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`| IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key. i.e: joe@ibm.com |              | Yes      |


### Executing the Terraform Script

Follow this link to execute this DB2 module: [Install IBM Cloud Pak DB2 Terraform Example](https://github.com/ibm-hcbt/terraform-ibm-cloud-pak/tree/main/examples/Db2)

### Verify

If DB2 is successful and the process is completed, you should see the following similar outputs:
```
Apply complete! Resources: 2 added, 0 changed, 2 destroyed.

Outputs:

db2_host_address =  @@@@@@@@@@@@-clust-c0b572361ba41c9eef42d4d51297b04b-0000.us-south.containers.appdomain.cloud                 
db2_ports =  00000,
 00001,
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

**Note**: The uninstall or cleanup process is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successful re-installation.
