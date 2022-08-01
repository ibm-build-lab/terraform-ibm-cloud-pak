# IBM Red Hat OpenShift Managed Cluster Parameters and Installation

## Set up

If running using your local Terraform Client, copy the appropriate `terraform.tfvars.classic` or `terraform.tfvars.vpc` to `terraform.tfvars` and ensure your values are set properly.  
 
## Input Parameters

The Terraform script requires the following list of input variables. Here are some instructions to set their values for Terraform and how to get their values from IBM Cloud. Pay attention to the parameters required for **Classic** vs **VPC**.


```hcl
# --------------------- CLOUD ---------------------- 
ibmcloud_api_key      = "******************"   // pragma: allowlist secret
iaas_classic_username = "******************"
resource_group        = "******************"
region                = "******************"

# --------------------- ROKS ---------------------- 
entitlement         = "cloud_pak"
roks_project_name   = "******************"
owner               = "******************"
environment         = "******************"
private_vlan        = "******************"
public_vlan         = "******************"
data_center         = "******************"
```

## Input Parameters and their Descriptions

| Name                               | Description                                                           | Default  | Required |
| ---------------------------------- | --------------------------------------------------------------------- | -------- | -------- |
| `ibmcloud_api_key`                 | IBM Cloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)|          | Yes      |
| `region`  | The region where the cluster will be created. List all available regions with: `ibmcloud regions` (https://cloud.ibm.com/docs/codeengine?topic=codeengine-regions)|        | No   |
| `resource_group` | Region where the cluster is created. Managing resource groups: (https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui) | `default` | Yes |
| `entitlement` | Enter `cloud_pak` if using a Cloud Pak entitlement. | `cloud_pak` | No |
| `roks_project_name` | The project name is used to name the cluster with the environment name. It's also used to label the cluster and other resources. Used to tag the cluster i.e. 'project:{project_name}' | `cloud-pak` | Yes   |
| `environment` | The environment name is used to label the cluster and other resources. Used to tag the cluster i.e. 'env:{environment}' | `dev` | No  |
| `owner`  | Use your user name or team name. The owner is used to label the cluster and other resources | `John Doe` | Yes  |
| `worker_zone` | The data center where the worker node is created. List all available zones with `ibmcloud ks locations` | `us-south` | Yes |
| `workers_count` | An array with the amount of workers on each workers group. On Classic it's only possible to have one workers group, so only the first number in the list is taken for the cluster size. Example: `[1, 3, 5]` or `[2]` | `[2]` | Yes |
| `worker_pool_flavor` | An array with the flavors or machine types of each of the workers.  List all flavors for each zone with: `ibmcloud ks flavors --zone dal10 --provider classic`. On Classic it is only possible to have one worker group, so only list one flavor, i.e. `["b3c.16x64"]`. | `["b3c.16x64"]` | No |
| `hardware` | The level of hardware isolation for your worker node. | `share` | No |
| `master_service_public_endpoint` | Enable the public service endpoint to make the master publicly accessible. | true | No |
| `force_delete_storage` | If set to `true`, force the removal of persistent storage associated with the cluster during cluster deletion. | `false` | Yes |
| `roks_version` | OpenShift version for the installation. List all available versions: `ibmcloud ks versions`. There is no need to include the suffix `_OpenShift`. The module will append it to install the specified version of OpenShift.  | `4.7` | No |
| `cluster_config_path` | Path to the Kubernetes configuration file to access your cluster. | `./.kube/config` | No |
| `private_vlan` | Private VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone`, make sure the the VLAN type is private and the router begins with **bc**. Use the ID or Number. This value may be empty if there isn't any VLAN in the Zone, however this may cause issues if the code is applied again. |   | No |
| `public_vlan` | Public VLAN assigned to your zone. List available VLANs in the zone: `ibmcloud ks vlan ls --zone`, make sure the the VLAN type is public and the router begins with **fc**. Use the ID or Number. This value may be empty if there isn't any VLAN in the Zone, however this may cause issues if the code is applied again. |   | No |
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


## Output Parameters

The module returns the following output variables:

| Name       | Description                                             |
| ---------- | ------------------------------------------------------- |
| `cp4aiops_aiman_url` | Access your Cloud Pak for AIOPS AIManager deployment at this URL. |
| `cp4aiops_aiman_user` | Username for your Cloud Pak for AIOPS AIManager deployment. |
| `cp4aiops_aiman_password` | Password for your Cloud Pak for AIOPSAIManager  deployment. |
| `cp4aiops_evtman_url` | Access your Cloud Pak for AIOP EventManager deployment at this URL. |
| `cp4aiops_evtman_user` | Username for your Cloud Pak for AIOPS EventManager deployment. |
| `cp4aiops_evtman_password` | Password for your Cloud Pak for AIOPS EventManager deployment. |

## Execute the example
Execute the following Terraform commands:
```hcl 
terraform init
terraform plan
terraform apply -auto-approve
```

### Verify
To verify installation on the cluster, go to the `Installed Operators` tab on the Openshift console. Choose your `namespace` and find `IBM Cloud Pak for Watson AIOps AI Manager` 3.x.x provided by IBM, and check the status. If it says `Succeded`, click on it then click again the `IBM Cloud Pak for Watson AIOps AI Manager` tab to check the status of `ibm-aiops` installation. 

To verify installation on the Kubernetes cluster, take the output URL, username and password and log into the CP4AIOps console.


## Cleanup

Go into the console and delete the platform navigator from the verify section. Delete all installed operators and lastly delete the project.

Finally, execute: `terraform destroy`.

If running locally, there are some directories and files you may want to manually delete, these are: `rm -rf terraform.tfstate* .terraform .kube`
