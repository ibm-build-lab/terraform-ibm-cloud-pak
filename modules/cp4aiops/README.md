# Terraform Module to install Cloud Pak for Watson AIOps

This Terraform Module installs **Cloud Pak for Watson AIOps** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `git::https://github.com/ibm-build-labs/terraform-ibm-cloud-pak.git//modules/cp4aiops`

- [Terraform Module to install Cloud Pak for Watson AIOps](#terraform-module-to-install-cloud-pak-for-aiops)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Setting up the OpenShift cluster](#setting-up-the-openshift-cluster)
  - [Installing the CP4AIOps Module](#installing-the-cp4aiops-module)
  - [Input Variables](#input-variables)
    - [Event Manager Options](#event-manager-options)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Accessing the Cloud Pak Console](#accessing-the-cloud-pak-console)
  - [Post Installation Instructions](#post-installation-instructions)
  - [Clean up](#clean-up)
  - [Troubleshooting](#troubleshooting)
  
## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../CREDENTIALS.md) for details.


### Setting up the OpenShift cluster

NOTE: an OpenShift cluster is required to install the Cloud Pak. This can be an existing cluster or can be provisioned using our `roks` Terraform module.

To provision a new cluster, refer [here](https://github.com/ibm-build-labs/terraform-ibm-cloud-pak/tree/main/modules/roks) for the code to add to your Terraform script. The recommended size for an OpenShift 4.7+ cluster on IBM Cloud Classic contains `9` workers (3 for `AIManager` and 6 for `EventManager`) of flavor `b3c.16x64`.

However please read the following documentation:
- [Cloud Pak for Watson AIOps documentation (AIManager)](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.2.1?topic=requirements-ai-manager)
- [Cloud Pak for Watson AIOps documentation (EventManager)](https://www.ibm.com/docs/en/noi/1.6.3?topic=preparing-sizing)

To confirm these parameters or if you are using IBM Cloud VPC or a different OpenShift version.

Add the following code to get the OpenShift cluster (new or existing) configuration:

```hcl
data "ibm_resource_group" "group" {
  name = var.resource_group
}

data "ibm_container_cluster_config" "cluster_config" {
  cluster_name_id   = var.cluster_name_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = true
  config_dir        = "./kube/config"     // Create this directory in advance
  admin             = false
  network           = false
}
```

**NOTE**: Create the `./kube/config` directory if it doesn't exist.

Input:

- `cluster_name_id`: either the cluster name or ID.

- `ibm_resource_group`:  resource group where the cluster is running

Output:

`ibm_container_cluster_config` used as input for the `cp4aiops` module

### Installing the CP4AIOPS Module

Use a `module` block assigning `source` to `git::https://github.com/ibm-build-labs/terraform-ibm-cloud-pak.git//modules/cp4aiops`. Then set the [input variables](#input-variables) required to install the Cloud Pak for Watson AIOps.

```hcl
module "cp4aiops" {
  source    = "./.."
  enable    = true

  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc
  portworx_is_ready   = 1          // Assuming portworx is installed if using VPC infrastructure

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // AIOps specific parameters:
  namespace            = var.namespace
  accept_aiops_license = var.accept_aiops_license
  enable_aimanager     = var.enable_aimanager
  enable_event_manager = var.enable_event_manager
}
```

## Input Variables

Name                             | Type   | Description                                                                                                                                        | Sensitive | Default
-------------------------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ----------------------------
ibmcloud_api_key                 |        | IBMCloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey                                                                      | true      | 
region                           |        | Region that cluster resides in                                                                                                                     |           | 
cluster_name_or_id               |        | Id of cluster for AIOps to be installed on                                                                                                         |           | 
resource_group_name              |        | Resource group that cluster resides in                                                                                                             |           | cloud-pak-sandbox-ibm
enable                           |        | If set to true installs Cloud-Pak for Data on the given cluster                                                                                    |           | true
cluster_config_path              |        | Path to the Kubernetes configuration file to access your cluster                                                                                   |           | 
on_vpc                           | bool   | If set to true, lets the module know cluster is using VPC Gen2                                                                                     |           | false
portworx_is_ready                | any    |                                                                                                                                                    |           | null
entitled_registry_key            |        | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary                                                              |           | 
entitled_registry_user_email     |        | Required: Email address of the user owner of the Entitled Registry Key                                                                             |           | 
namespace                        |        | Namespace for Cloud Pak for AIOps                                                                                                                  |           | cpaiops
accept_aiops_license             | bool   | Do you accept the licensing agreement for aiops? `T/F`                                                                                             |           | false
enable_aimanager                 | bool   | Install AIManager? `T/F`                                                                                                                           |           | true
enable_event_manager             | bool   | Install Event Manager? `T/F`                                                                                                                       |           | true

**NOTE** The boolean input variable `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.

For an example of how to put all this together, refer to our [Cloud Pak for Watson AIOps Terraform script](https://github.com/ibm-build-labs/cloud-pak-sandboxes/tree/master/terraform/cp4aiops).

## Event Manager Options

Name                             | Type   | Description                                                                                                                                        | Sensitive | Default
-------------------------------- | ------ | -------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ----------------------------
enable_persistence               | bool   | Enables persistence storage for kafka, cassandra, couchdb, and others. Default is `true`                                                           |           | true
humio_repo                       | string | To enable Humio search integrations, provide the Humio Repository for your Humio instance                                                          |           | 
humio_url                        | string | To enable Humio search integrations, provide the Humio Base URL of your Humio instance (on-prem/cloud)                                             |           | 
ldap_port                        | number | Configure the port of your organization's LDAP server.                                                                                             |           | 3389
ldap_mode                        | string | Choose `standalone` for a built-in LDAP server or `proxy` and connect to an external organization LDAP server. See http://ibm.biz/install_noi_icp. |           | standalone
ldap_storage_class               | string | LDAP Storage class - note: only needed for `standalone` mode                                                                                       |           | 
ldap_user_filter                 | string | LDAP User Filter                                                                                                                                   |           | uid=%s,ou=users
ldap_bind_dn                     | string | Configure LDAP bind user identity by specifying the bind distinguished name (bind DN).                                                             |           | cn=admin,dc=mycluster,dc=icp
ldap_ssl_port                    | number | Configure the SSL port of your organization's LDAP server.                                                                                         |           | 3636
ldap_url                         | string | Configure the URL of your organization's LDAP server.                                                                                              |           | ldap://localhost:3389
ldap_suffix                      | string | Configure the top entry in the LDAP directory information tree (DIT).                                                                              |           | dc=mycluster,dc=icp
ldap_group_filter                | string | LDAP Group Filter                                                                                                                                  |           | cn=%s,ou=groups
ldap_base_dn                     | string | Configure the LDAP base entry by specifying the base distinguished name (DN).                                                                      |           | dc=mycluster,dc=icp
ldap_server_type                 | string | LDAP Server Type. Set to `CUSTOM` for non Active Directory servers. Set to `AD` for Active Directory                                               |           | CUSTOM
continuous_analytics_correlation | bool   | Enable Continuous Analytics Correlation                                                                                                            |           | false
backup_deployment                | bool   | Is this a backup deployment?                                                                                                                       |           | false
zen_deploy                       | bool   | Flag to deploy NOI cpd in the same namespace as aimanager                                                                                          |           | false
zen_ignore_ready                 | bool   | Flag to deploy zen customization even if not in ready state                                                                                        |           | false
zen_instance_name                | string | Application Discovery Certificate Secret (If Application Discovery is enabled)                                                                     |           | iaf-zen-cpdservice
zen_instance_id                  | string | ID of Zen Service Instance                                                                                                                         |           | 
zen_namespace                    | string | Namespace of the ZenService Instance                                                                                                               |           | 
zen_storage                      | string | The Storage Class Name                                                                                                                             |           | 
enable_app_discovery             | bool   | Enable Application Discovery and Application Discovery Observer                                                                                    |           | false
ap_cert_secret                   | string | Application Discovery Certificate Secret (If Application Discovery is enabled)                                                                     |           | 
ap_db_secret                     | string | Application Discovery DB2 secret (If Application Discovery is enabled)                                                                             |           | 
ap_db_host_url                   | string | Application Discovery DB2 host to connect (If Application Discovery is enabled)                                                                    |           | 
ap_secure_db                     | bool   | Application Discovery Secure DB connection (If Application Discovery is enabled)                                                                   |           | false
enable_network_discovery         | bool   | Enable Network Discovery and Network Discovery Observer                                                                                            |           | false
obv_alm                          | bool   | Enable ALM Topology Observer                                                                                                                       |           | false
obv_ansibleawx                   | bool   | Enable Ansible AWX Topology Observer                                                                                                               |           | false
obv_appdynamics                  | bool   | Enable AppDynamics Topology Observer                                                                                                               |           | false
obv_aws                          | bool   | Enable AWS Topology Observer                                                                                                                       |           | false
obv_azure                        | bool   | Enable Azure Topology Observer                                                                                                                     |           | false
obv_bigfixinventory              | bool   | Enable BigFixInventory Topology Observer                                                                                                           |           | false
obv_cienablueplanet              | bool   | Enable CienaBluePlanet Topology Observer                                                                                                           |           | false
obv_ciscoaci                     | bool   | Enable CiscoAci Topology Observer                                                                                                                  |           | false
obv_contrail                     | bool   | Enable Contrail Topology Observer                                                                                                                  |           | false
obv_dns                          | bool   | Enable DNS Topology Observer                                                                                                                       |           | false
obv_docker                       | bool   | Enable Docker Topology Observer                                                                                                                    |           | false
obv_dynatrace                    | bool   | Enable Dynatrace Topology Observer                                                                                                                 |           | false
obv_file                         | bool   | Enable File Topology Observer                                                                                                                      |           | true
obv_googlecloud                  | bool   | Enable GoogleCloud Topology Observer                                                                                                               |           | false
obv_ibmcloud                     | bool   | Enable IBMCloud Topology Observer                                                                                                                  |           | false
obv_itnm                         | bool   | Enable ITNM Topology Observer                                                                                                                      |           | false
obv_jenkins                      | bool   | Enable Jenkins Topology Observer                                                                                                                   |           | false
obv_junipercso                   | bool   | Enable JuniperCSO Topology Observer                                                                                                                |           | false
obv_kubernetes                   | bool   | Enable Kubernetes Topology Observer                                                                                                                |           | true
obv_newrelic                     | bool   | Enable NewRelic Topology Observer                                                                                                                  |           | false
obv_openstack                    | bool   | Enable OpenStack Topology Observer                                                                                                                 |           | false
obv_rancher                      | bool   | Enable Rancher Topology Observer                                                                                                                   |           | false
obv_rest                         | bool   | Enable Rest Topology Observer                                                                                                                      |           | true
obv_servicenow                   | bool   | Enable ServiceNow Topology Observer                                                                                                                |           | true
obv_taddm                        | bool   | Enable TADDM Topology Observer                                                                                                                     |           | false
obv_vmvcenter                    | bool   | Enable VMVcenter Topology Observer                                                                                                                 |           | true
obv_vmwarensx                    | bool   | Enable VMWareNSX Topology Observer                                                                                                                 |           | false
obv_zabbix                       | bool   | Enable Zabbix Topology Observer                                                                                                                    |           | false
enable_backup_restore            | bool   | Enable Analytics Backups                                                                                                                           |           | false


## Executing the Terraform Script

Execute the following commands to install the Cloud Pak:

```bash
terraform init
terraform plan
terraform apply
```

## Accessing the Cloud Pak Console

After execution has completed, access the cluster using `kubectl` or `oc`:

```bash
ibmcloud oc cluster config -c <cluster-name> --admin
oc get route -n ${NAMESPACE} cpd -o jsonpath=‘{.spec.host}’ && echo
```

To get default login id:

```bash
oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 -d && echo
```

To get default Password:

```bash
oc -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d && echo
```

## Post Installation Instructions

This section is _REQUIRED_ if you install AIManager and EventManager. 

Please follow the documentation starting at `step 3` to `step 9` [here](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.2.1?topic=installing-ai-manager-event-manager) for further info.


## Clean up

When you finish using the cluster, release the resources by executing the following command:

```bash
terraform destroy
```
