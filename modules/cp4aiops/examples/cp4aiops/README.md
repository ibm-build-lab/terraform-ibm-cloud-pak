# Example to provision CP4AIOps Terraform module

## Requirements for AIOps

**NOTE:** an OpenShift cluster is required to install this module. This can be an existing cluster or can be provisioned using our [roks](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/roks) Terraform module.

The recommended size for an OpenShift 4.7+ cluster on IBM Cloud Classic contains `9` workers (3 for `AIManager` and 6 for `EventManager`) of flavor `16x64`. However please read the following documentation:
- [Cloud Pak for Watson AIOps documentation (AIManager)](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.2.1?topic=requirements-ai-manager)
- [Cloud Pak for Watson AIOps documentation (EventManager)](https://www.ibm.com/docs/en/noi/1.6.3?topic=preparing-sizing)

  
## Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](../Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).


## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md) 

Customize desired input values in a `terraform.tfvars` file:

```hcl
  cluster_name_or_id    = "******************"
  on_vpc                = true
  region                = "us-south"
  resource_group_name   = "Default"
  entitled_registry_key = "******************"
  entitled_registry_user_email = "john.doe@email.com"
  namespace             = "cp4aiops"
  ibmcloud_api_key      = "******************"
  accept_aimanager_license  = "true"
  accept_event_manager_license  = "true"
```

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Inputs

| Name                               | Description                                                           | Default  | Required |
| ---------------------------------- | --------------------------------------------------------------------- | -------- | -------- |
| `ibmcloud_api_key`                 | IBM Cloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)|          | Yes      |
| `cluster_name_or_id`  | Cluster name or id to install Cloud Pak on |        | No   |
| `on_vpc`  | Set to true if the cluster is vpc. **NOTE** Portworx must be installed if using a VPC cluster |    `false`    | No   |
| `namespace`  | Name of the namespace cp4aiops will be installed into |   `cp4aiops`     | No   |
| `region`  | The region where the cluster will be created. List all available regions with: `ibmcloud regions` (https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions)|        | No   |
| `resource_group_name` | Region where the cluster is created. Managing resource groups: (https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui) | `default` | Yes |
| `cluster_config_path` | Directory to store the kubeconfig file, set the value to empty string to not download the config. If running on Schematics, use `/tmp/.schematics/.kube/config` | `./.kube/config` | No |
| `accept_aimanager_license` | The license agreement for AIManager | `false` | No |
| `accept_event_manager_license` | The license agreement for EventManager | `false` | No |
| `entitled_registry_key` | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the file() function to get the file content/key |   | Yes |
| `entitled_registry_user_email` | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key. i.e: joe@ibm.com | | Yes |
| `enable_persistence` | Enables persistence storage for kafka, cassandra, couchdb, and others. | `true` | No |
| `humio_repo` | To enable Humio search integrations, provide the Humio Repository for your Humio instance |  | No |
| `humio_url` | To enable Humio search integrations, provide the Humio Base URL of your Humio instance (on-prem/cloud) |  | No |
| `ldap_port` | Configure the port of your organization's LDAP server. | `3389` | No | 
| `ldap_mode` | Choose `standalone` for a built-in LDAP server or `proxy` and connect to an external organization LDAP server. See http://ibm.biz/install_noi_icp.| `standalone` | No |
| `ldap_user_filter` | LDAP User Filter | `uid=%s,ou=users` | No |
| `ldap_bind_dn` | Configure LDAP bind user identity by specifying the bind distinguished name (bind DN). | `cn=admin,dc=mycluster,dc=icp` | No | 
| `ldap_ssl_port` | Configure the SSL port of your organization's LDAP server. | `3636` | No |
| `ldap_url` | Configure the URL of your organization's LDAP server. | `ldap://localhost:3389` | No |
| `ldap_suffix` | Configure the top entry in the LDAP directory information tree (DIT). | `dc=mycluster,dc=icp` | No |
| `ldap_group_filter` | LDAP Group Filter | `cn=%s,ou=groups` | No |
| `ldap_base_dn` | Configure the LDAP base entry by specifying the base distinguished name (DN). | `dc=mycluster,dc=icp` | No |
| `ldap_server_type` | LDAP Server Type. Set to `CUSTOM` for non Active Directory servers. Set to `AD` for Active Directory | `CUSTOM` | No |
| `continuous_analytics_correlation` | Enable Continuous Analytics Correlation | `false` | No |
| `backup_deployment` | For backing up the deployment | `false` | No |
| `zen_deploy` | Flag to deploy NOI cpd in the same namespace as aimanager | `false` | No |
| `zen_ignore_ready` | Flag to deploy zen customization even if not in ready state | `false` | No |
| `zen_instance_name` | Application Discovery Certificate Secret (If Application Discovery is enabled) | `iaf-zen-cpdservice` | No | 
| `zen_instance_id` | ID of Zen Service Instance | | No |
| `zen_namespace` | Namespace of the ZenService Instance | | No |
| `zen_storage` | The storage class name |  | No |
| `enable_app_discovery` | Enable Application Discovery and Application Discovery Observer | `false` | No |
| `ap_cert_secret` | Application Discovery Certificate Secret (If Application Discovery is enabled) | | No |
| `ap_db_secret` | Application Discovery DB2 secret (If Application Discovery is enabled) |  | No |
| `ap_db_host_url` | Application Discovery DB2 host to connect (If Application Discovery is enabled) |  | No |
| `ap_secure_db` | Application Discovery Secure DB connection (If Application Discovery is enabled) | `false` | No |
| `enable_network_discovery` | Enable Network Discovery and Network Discovery Observer | `false` | No |
| `obv_alm` | Enable ALM Topology Observer | `false` | No |
| `obv_ansibleawx` | Enable Ansible AWX Topology Observer | `false` | No |
| `obv_appdynamics` | Enable AppDynamics Topology Observer | `false` | No |
| `obv_aws` | Enable AWS Topology Observer | `false` | No |
| `obv_azure` | Enable Azure Topology Observer | `false` | No |
| `obv_bigfixinventory` | Enable BigFixInventory Topology Observer | `false` | No |
| `obv_cienablueplanet` | Enable CienaBluePlanet Topology Observer | `false` | No |
| `obv_ciscoaci` | Enable CiscoAci Topology Observer | `false` | No |
| `obv_contrail` | Enable Contrail Topology Observer | `false` | No |
| `obv_dns` | Enable DNS Topology Observer | `false` | No |
| `obv_docker` | Enable Docker Topology Observer | `false` | No |
| `obv_dynatrace` | Enable Dynatrace Topology Observer | `false` | No |
| `obv_file` | Enable File Topology Observer | `true` | No |
| `obv_googlecloud` | Enable GoogleCloud Topology Observer | `false` | No |
| `obv_ibmcloud` | Enable IBMCloud Topology Observer | `false` | No |
| `obv_itnm` | Enable ITNM Topology Observer | `false` | No |
| `obv_jenkins` | Enable Jenkins Topology Observer | `false` | No |
| `obv_junipercso` | Enable JuniperCSO Topology Observer | `false` | No |
| `obv_kubernetes` | Enable Kubernetes Topology Observer | `false` | No | 
| `obv_newrelic` | Enable NewRelic Topology Observer | `false` | No |
| `obv_openstack` | Enable OpenStack Topology Observer | `false` | No |
| `obv_rancher` | Enable Rancher Topology Observer | `false` | No |
| `obv_rest` | Enable Rest Topology Observer | `true` | No |
| `obv_servicenow` | Enable ServiceNow Topology Observer | `true` | No |
| `obv_taddm` | Enable TADDM Topology Observer | `false` | No |
| `obv_vmvcenter` | Enable VMVcenter Topology Observer | `false` | No |
| `obv_vmwarensx` | Enable VMWareNSX Topology Observer | `false` | No |
| `obv_zabbix` | Enable Zabbix Topology Observer | `false` | No |
| `enable_backup_restore` | Enable Analytics Backups | `false` | No |

## Outputs

The module returns the following output variables:

| Name       | Description                                             |
| ---------- | ------------------------------------------------------- |
| `cp4aiops_aiman_url` | Access your Cloud Pak for AIOPS AIManager deployment at this URL. |
| `cp4aiops_aiman_user` | Username for your Cloud Pak for AIOPS AIManager deployment. |
| `cp4aiops_aiman_password` | Password for your Cloud Pak for AIOPSAIManager  deployment. |
| `cp4aiops_evtman_url` | Access your Cloud Pak for AIOP EventManager deployment at this URL. |
| `cp4aiops_evtman_user` | Username for your Cloud Pak for AIOPS EventManager deployment. |
| `cp4aiops_evtman_password` | Password for your Cloud Pak for AIOPS EventManager deployment. |


## Verify

To verify installation on the Kubernetes cluster, take the output URL, username and password and log into the CP4AIOps console.

## Post Installation

This section is _REQUIRED_ if AIManager and EventManager are enabled. 

Please follow the documentation starting at `step 3` to `step 9` [here](https://www.ibm.com/docs/en/cloud-paks/cloud-pak-watson-aiops/3.2.1?topic=installing-ai-manager-event-manager) for further info.


## Cleanup

Go into the console and delete the installation `ibm-cp-watson-aiops` from the installations tab located within the IBM Cloud Pak for Watson AIOps operaator. Next, delete all installed operators and lastly delete the project.

Finally, execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf terraform.tfstate* .terraform .kube`
