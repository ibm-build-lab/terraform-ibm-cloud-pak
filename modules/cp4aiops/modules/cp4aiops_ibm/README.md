# Terraform Module to install Cloud Pak for Watson AIOps

**NOTE: This module has been deprecated and is no longer supported. **

This Terraform Module installs **Cloud Pak for Watson AIOps** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4aiops`

**NOTE:** an OpenShift cluster is required to install this module. This can be an existing cluster or can be provisioned using our [roks](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/roks) Terraform module.

The recommended size for an OpenShift 4.7+ cluster on IBM Cloud Classic contains `9` workers (3 for `AIManager` and 6 for `EventManager`) of flavor `16x64`. However please read the following documentation:
- [Cloud Pak for Watson AIOps documentation (AIManager)](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.2.1?topic=requirements-ai-manager)
- [Cloud Pak for Watson AIOps documentation (EventManager)](https://www.ibm.com/docs/en/noi/1.6.3?topic=preparing-sizing)

To confirm these parameters or if you are using IBM Cloud VPC or a different OpenShift version.

### Provisioning the CP4AIOPS Module

Use a `module` block assigning the `source` parameter to the location of this module. Then set the required [input variables](#inputs).

```hcl
module "cp4aiops" {
  source    = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4aiops/modules/cp4aiops_ibm"
  enable    = true
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc
  portworx_is_ready   = 1          // Assuming portworx is installed if using VPC infrastructure

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // AIOps specific parameters:
  accept_aimanager_license     = var.accept_aimanager_license
  accept_event_manager_license = var.accept_event_manager_license
  namespace            = "aiops"
  enable_aimanager     = true

  //************************************
  // EVENT MANAGER OPTIONS START *******
  //************************************
  enable_event_manager = true

  // Persistence option
  enable_persistence               = var.enable_persistence

  // Integrations - humio
  humio_repo                       = var.humio_repo
  humio_url                        = var.humio_url

  // LDAP options
  ldap_port                        = var.ldap_port
  ldap_mode                        = var.ldap_mode
  ldap_user_filter                 = var.ldap_user_filter
  ldap_bind_dn                     = var.ldap_bind_dn
  ldap_ssl_port                    = var.ldap_ssl_port
  ldap_url                         = var.ldap_url
  ldap_suffix                      = var.ldap_suffix
  ldap_group_filter                = var.ldap_group_filter
  ldap_base_dn                     = var.ldap_base_dn
  ldap_server_type                 = var.ldap_server_type

  // Service Continuity
  continuous_analytics_correlation = var.continuous_analytics_correlation
  backup_deployment                = var.backup_deployment

  // Zen Options
  zen_deploy                       = var.zen_deploy
  zen_ignore_ready                 = var.zen_ignore_ready
  zen_instance_name                = var.zen_instance_name
  zen_instance_id                  = var.zen_instance_id
  zen_namespace                    = var.zen_namespace
  zen_storage                      = var.zen_storage

  // TOPOLOGY OPTIONS:
  // App Discovery -
  enable_app_discovery             = var.enable_app_discovery
  ap_cert_secret                   = var.ap_cert_secret
  ap_db_secret                     = var.ap_db_secret
  ap_db_host_url                   = var.ap_db_host_url
  ap_secure_db                     = var.ap_secure_db
  // Network Discovery
  enable_network_discovery         = var.enable_network_discovery
  // Observers
  obv_docker                       = var.obv_docker
  obv_taddm                        = var.obv_taddm
  obv_servicenow                   = var.obv_servicenow
  obv_ibmcloud                     = var.obv_ibmcloud
  obv_alm                          = var.obv_alm
  obv_contrail                     = var.obv_contrail
  obv_cienablueplanet              = var.obv_cienablueplanet
  obv_kubernetes                   = var.obv_kubernetes
  obv_bigfixinventory              = var.obv_bigfixinventory
  obv_junipercso                   = var.obv_junipercso
  obv_dns                          = var.obv_dns
  obv_itnm                         = var.obv_itnm
  obv_ansibleawx                   = var.obv_ansibleawx
  obv_ciscoaci                     = var.obv_ciscoaci
  obv_azure                        = var.obv_azure
  obv_rancher                      = var.obv_rancher
  obv_newrelic                     = var.obv_newrelic
  obv_vmvcenter                    = var.obv_vmvcenter
  obv_rest                         = var.obv_rest
  obv_appdynamics                  = var.obv_appdynamics
  obv_jenkins                      = var.obv_jenkins
  obv_zabbix                       = var.obv_zabbix
  obv_file                         = var.obv_file
  obv_googlecloud                  = var.obv_googlecloud
  obv_dynatrace                    = var.obv_dynatrace
  obv_aws                          = var.obv_aws
  obv_openstack                    = var.obv_openstack
  obv_vmwarensx                    = var.obv_vmwarensx

  // Backup Restore
  enable_backup_restore            = var.enable_backup_restore

  //************************************
  // EVENT MANAGER OPTIONS END *******
  //************************************
}
```

For an example on how to provision and execute this module go [here](../../examples/cp4aiops).


## Inputs

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
