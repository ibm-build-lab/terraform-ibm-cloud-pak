########## ROKS VARIABLES #########

variable "ibmcloud_api_key" {
  description = "IBMCloud API key (https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)"
}

variable "region" {
  description = "The region where the cluster will be created. List all available regions with: `ibmcloud regions`"
  type        = string
}

variable "resource_group" {
  default     = "default"
  description = "Region where the cluster is created. Managing resource groups: (https://cloud.ibm.com/docs/account?topic=account-rgs&interface=ui)"
}

variable "entitlement" {
  description = "create your cluster with existing entitlement"
  type        = string
  default     = "cloud_pak"
}

variable "roks_project_name" {
  default     = "cp4aiops"
  description = "The project name is used to name the cluster with the environment name. It's also used to label the cluster and other resources. Used to tag the cluster i.e. 'project:{project_name}'"
}

variable "environment" {
  default     = "dev"
  description = "Used to tag the cluster i.e. 'env:{environment}'"
}

variable "owner" {
  default     = ""
  description = "Used to tag the cluster i.e. 'owner:{owner}'"
}

variable "worker_zone" {
  description = "The data center where the worker node is created. List all available zones with `ibmcloud ks locations`"
  default     = "dal12"
  type        = string
}

variable "workers_count" {
  description = "Number of worker nodes per zone"
  type        = number
  default     = 4
}

variable "worker_pool_flavor" {
  description = "The machine type for your worker node."
  type        = string
  default     = "b3c.16x64"
}

variable "hardware" {
  description = "The level of hardware isolation for your worker node."
  type        = string
  default     = "shared"
}

variable "master_service_public_endpoint" {
  description = "Enable the public service endpoint to make the master publicly accessible."
  type        = bool
  default     = true
}

variable "force_delete_storage" {
  description = "force the removal of persistent storage associated with the cluster during cluster deletion."
  type        = bool
  default     = null
}

variable "roks_version" {
  description = "The OpenShift version that you want to set up in your cluster."
  type        = string
  default     = 4.7
}

variable "cluster_config_path" {
  default     = "./.kube/config/"
  type        = string
  description = "Defaulted to `./.kube/config` but for schematics, use `/tmp/.schematic/.kube/config`"
}

variable "public_vlan" {
  description = "The ID of the public VLAN that you want to use for your worker nodes. List available VLANs in the zone: `ibmcloud target -g <resource-group>; ibmcloud ks vlan ls --zone <zone>`"
  type        = string
  default     = null
}

variable "private_vlan" {
  description = "The ID of the private VLAN that you want to use for your worker nodes. List available VLANs in the zone: `ibmcloud target -g <resource-group>; ibmcloud ks vlan ls --zone <zone>`"
  type        = string
  default     = null
}

locals {
  on_vpc     = false
//  type        = bool
//  description = "If set to true, lets the module know cluster is using VPC Gen2"
}

locals {
  cluster_name = "${var.roks_project_name}-${var.environment}-${random_string.this.result}"
  roks_version = format("%s_openshift", split("_", var.roks_version)[0])
}


######### AIOPS VARIABLES #########

variable "accept_aimanager_license" {
  default = false
  type = bool
  description = "Do you accept the licensing agreement for AIManager? `T/F`"
}

variable "accept_event_manager_license" {
  default = false
  type = bool
  description = "Do you accept the licensing agreement for EventManager? `T/F`"
}

variable "entitled_registry_key" {
  type        = string
  description = "Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary"
}

variable "entitled_registry_user_email" {
  type        = string
  description = "Docker email address"
}

#############################################
# Event Manager Options
#############################################

# PERSISTENCE
variable "enable_persistence" {
  default = true
  type = bool
  description = "Enables persistence storage for kafka, cassandra, couchdb, and others. Default is `true`"
}

# INTEGRATIONS - HUMIO
variable "humio_repo" {
  default = ""
  type = string
  description = "To enable Humio search integrations, provide the Humio Repository for your Humio instance"
}

variable "humio_url" {
  default = ""
  type = string
  description = "To enable Humio search integrations, provide the Humio Base URL of your Humio instance (on-prem/cloud)"
}


# LDAP:
variable "ldap_port" {
  default = "3389"
  type = number
  description = "Configure the port of your organization's LDAP server."
}

variable "ldap_mode" {
  default = "standalone"
  type = string
  description = "Choose `standalone` for a built-in LDAP server or `proxy` and connect to an external organization LDAP server. See http://ibm.biz/install_noi_icp."
}

variable "ldap_user_filter" {
  default = "uid=%s,ou=users"
  type = string
  description = "LDAP User Filter"
}

variable "ldap_bind_dn" {
  default = "cn=admin,dc=mycluster,dc=icp"
  type = string
  description = "Configure LDAP bind user identity by specifying the bind distinguished name (bind DN)."
}

variable "ldap_ssl_port" {
  default = "3636"
  type = number
  description = "Configure the SSL port of your organization's LDAP server."
}

variable "ldap_url" {
  default = "ldap://localhost:3389"
  type = string
  description = "Configure the URL of your organization's LDAP server."
}

variable "ldap_suffix" {
  default = "dc=mycluster,dc=icp"
  type = string
  description = "Configure the top entry in the LDAP directory information tree (DIT)."
}

variable "ldap_group_filter" {
  default = "cn=%s,ou=groups"
  type = string
  description = "LDAP Group Filter"
}

variable "ldap_base_dn" {
  default = "dc=mycluster,dc=icp"
  type = string
  description = "Configure the LDAP base entry by specifying the base distinguished name (DN)."
}

variable "ldap_server_type" {
  default = "CUSTOM"
  type = string
  description = "LDAP Server Type. Set to `CUSTOM` for non Active Directory servers. Set to `AD` for Active Directory"
}

# SERVICE CONTINUITY: 
variable "continuous_analytics_correlation" {
  default = false
  type = bool
  description = "Enable Continuous Analytics Correlation"
}

variable "backup_deployment" {
  default = false
  type = bool
  description = "Is this a backup deployment?"
}

# ZEN OPTIONS:
variable "zen_deploy" {
  default = false
  type = bool
  description = "Flag to deploy NOI cpd in the same namespace as aimanager"
}
variable "zen_ignore_ready" {
  default = false
  type = bool
  description = "Flag to deploy zen customization even if not in ready state"
}
variable "zen_instance_name" {
  default = "iaf-zen-cpdservice"
  type = string
  description = "Application Discovery Certificate Secret (If Application Discovery is enabled)"
}
variable "zen_instance_id" {
  default = ""
  type = string
  description = "ID of Zen Service Instance"
}
variable "zen_namespace" {
  default = ""
  type = string
  description = "Namespace of the ZenService Instance"
}
variable "zen_storage" {
  default = ""
  type = string
  description = "The Storage Class Name"
}

# TOPOLOGY OPTIONS:
# App Discovery -
variable "enable_app_discovery" {
  default = false
  type = bool
  description = "Enable Application Discovery and Application Discovery Observer"
}

variable "ap_cert_secret" {
  default = ""
  type = string
  description = "Application Discovery Certificate Secret (If Application Discovery is enabled)"
}

variable "ap_db_secret" {
  default = ""
  type = string
  description = "Application Discovery DB2 secret (If Application Discovery is enabled)"
}

variable "ap_db_host_url" {
  default = ""
  type = string
  description = "Application Discovery DB2 host to connect (If Application Discovery is enabled)"
}

variable "ap_secure_db" {
  default = false
  type = bool
  description = "Application Discovery Secure DB connection (If Application Discovery is enabled)"
}

#Network Discovery
variable "enable_network_discovery" {
  default = false
  type = bool
  description = "Enable Network Discovery and Network Discovery Observer"
}

#Observers
variable "obv_alm" {
  default = false
  type = bool
  description = "Enable ALM Topology Observer"
}

variable "obv_ansibleawx" {
  default = false
  type = bool
  description = "Enable Ansible AWX Topology Observer"
}

variable "obv_appdynamics" {
  default = false
  type = bool
  description = "Enable AppDynamics Topology Observer"
}

variable "obv_aws" {
  default = false
  type = bool
  description = "Enable AWS Topology Observer"
}

variable "obv_azure" {
  default = false
  type = bool
  description = "Enable Azure Topology Observer"
}

variable "obv_bigfixinventory" {
  default = false
  type = bool
  description = "Enable BigFixInventory Topology Observer"
}

variable "obv_cienablueplanet" {
  default = false
  type = bool
  description = "Enable CienaBluePlanet Topology Observer"
}

variable "obv_ciscoaci" {
  default = false
  type = bool
  description = "Enable CiscoAci Topology Observer"
}

variable "obv_contrail" {
  default = false
  type = bool
  description = "Enable Contrail Topology Observer"
}

variable "obv_dns" {
  default = false
  type = bool
  description = "Enable DNS Topology Observer"
}

variable "obv_docker" {
  default = false
  type = bool
  description = "Enable Docker Topology Observer"
}

variable "obv_dynatrace" {
  default = false
  type = bool
  description = "Enable Dynatrace Topology Observer"
}

variable "obv_file" {
  default = true
  type = bool
  description = "Enable File Topology Observer"
}

variable "obv_googlecloud" {
  default = false
  type = bool
  description = "Enable GoogleCloud Topology Observer"
}

variable "obv_ibmcloud" {
  default = false
  type = bool
  description = "Enable IBMCloud Topology Observer"
}

variable "obv_itnm" {
  default = false
  type = bool
  description = "Enable ITNM Topology Observer"
}

variable "obv_jenkins" {
  default = false
  type = bool
  description = "Enable Jenkins Topology Observer"
}

variable "obv_junipercso" {
  default = false
  type = bool
  description = "Enable JuniperCSO Topology Observer"
}

variable "obv_kubernetes" {
  default = true
  type = bool
  description = "Enable Kubernetes Topology Observer"
}

variable "obv_newrelic" {
  default = false
  type = bool
  description = "Enable NewRelic Topology Observer"
}

variable "obv_openstack" {
  default = false
  type = bool
  description = "Enable OpenStack Topology Observer"
}

variable "obv_rancher" {
  default = false
  type = bool
  description = "Enable Rancher Topology Observer"
}

variable "obv_rest" {
  default = true
  type = bool
  description = "Enable Rest Topology Observer"
}

variable "obv_servicenow" {
  default = true
  type = bool
  description = "Enable ServiceNow Topology Observer"
}

variable "obv_taddm" {
  default = false
  type = bool
  description = "Enable TADDM Topology Observer"
}

variable "obv_vmvcenter" {
  default = true
  type = bool
  description = "Enable VMVcenter Topology Observer"
}

variable "obv_vmwarensx" {
  default = false
  type = bool
  description = "Enable VMWareNSX Topology Observer"
}

variable "obv_zabbix" {
  default = false
  type = bool
  description = "Enable Zabbix Topology Observer"
}

# BACKUP RESTORE
variable "enable_backup_restore" {
  default = false
  type = bool
  description = "Enable Analytics Backups"
}

locals {
  docker_registry          = "cp.icr.io" // Staging: "cp.stg.icr.io/cp/cpd"
  docker_username          = "cp"               // "ekey"
  entitled_registry_key    = chomp(var.entitled_registry_key)
}