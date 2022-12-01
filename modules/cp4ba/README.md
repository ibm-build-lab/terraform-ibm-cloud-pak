# Terraform Module to install Cloud Pak for Business Automation

This Terraform Module installs **Cloud Pak for Business Automation** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4ba`

NOTE: an OpenShift cluster is required to install the Cloud Pak. This can be an existing cluster or can be provisioned using our [roks](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/roks.) Terraform module.

The recommended size for an OpenShift cluster contains `5` workers of size `16x64`, however read the [Cloud Pak for Business Automation documentation](https://www.ibm.com/docs/en/cloud-paks/cp-biz-automation) to confirm these parameters.

### Provisioning the CP4BA Module

Use a `module` block assigning the `source` parameter to the location of this module. Then set the required [input variables](#inputs).

```hcl
module "install_cp4ba" {
  source = "`github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4ba"
  enable_cp4ba           = true
  enable_db2             = true
  ibmcloud_api_key       = var.ibmcloud_api_key
  region                 = var.region
  cluster_config_path    = var.cluster_config_path
  ingress_subdomain      = var.ingress_subdomain
  # ---- Platform ----
  cp4ba_project_name     = var.cp4ba_project_name
  entitled_registry_user_email = var.entitled_registry_user_email
  entitled_registry_key        = var.entitled_registry_key
  # ----- LDAP Settings -----
  ldap_admin_name         = var.ldap_admin_name
  ldap_admin_password     = var.ldap_admin_password
  ldap_host_ip            = var.ldap_host_ip
  # ----- DB2 Settings -----
  db2_ports               = var.db2_ports
  db2_host_address        = var.db2_host_address
  db2_admin_username      = var.db2_admin_username
  db2_admin_user_password = var.db2_admin_user_password
}
```

## Input Variables

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


For an example of how to provision and execute this module go to [IBM Cloud Pak Business Automation (CP4BA) Terraform Example](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/examples/cp4ba)

### Verify

If CP4BA is successful and the process is completed, you should see the following similar outputs:

```console

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


## Clean up or Uninstall CP4BA

When you finish with CP4BA, release the resources by executing the following command:

```bash
terraform destroy
```

Additional resources are creating using scripts. The cleanup process for these additional resources is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successful re-installation.
