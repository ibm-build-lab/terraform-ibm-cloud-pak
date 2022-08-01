provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.region
}

resource "random_string" "this" {
  length  = 6
  special = false
  upper   = false
}

data "ibm_resource_group" "rg" {
  name = var.resource_group
}

module "classic-openshift-single-zone-cluster" {
  source = "terraform-ibm-modules/cluster/ibm//modules/classic-openshift-single-zone"

  // Openshift parameters:
  cluster_name          = local.cluster_name
  worker_zone           = var.worker_zone
  hardware              = var.hardware
  resource_group_id     = data.ibm_resource_group.rg.id
  worker_nodes_per_zone = (var.workers_count != null ? var.workers_count : 1)
  worker_pool_flavor    = (var.worker_pool_flavor != null ? var.worker_pool_flavor : null)
  public_vlan           = (var.public_vlan != null ? var.public_vlan : null)
  private_vlan          = (var.private_vlan != null ? var.private_vlan : null)
  kube_version          = local.roks_version
  tags                  = ["project:${var.roks_project_name}", "env:${var.environment}", "owner:${var.owner}"]
  entitlement           = (var.entitlement != null ? var.entitlement : "")
}


resource "time_sleep" "wait_for_ingress" {
  depends_on = [module.classic-openshift-single-zone-cluster]

  create_duration = "800s"
}


resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "mkdir -p ${var.cluster_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on        = [null_resource.mkdir_kubeconfig_dir, time_sleep.wait_for_ingress]
  cluster_name_id   = module.classic-openshift-single-zone-cluster.classic_openshift_cluster_id
  resource_group_id = data.ibm_resource_group.rg.id
  config_dir        = var.cluster_config_path
  admin             = true
  download          = true
  network           = false
}

// Module:
module "cp4aiops" {
  depends_on = [data.ibm_container_cluster_config.cluster_config]

  source    = "../../modules/cp4aiops"

  cluster_config_path      = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc                   = false
  portworx_is_ready        = 1          // Assuming portworx is installed if using VPC infrastructure

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // AIOps specific parameters:
  accept_aimanager_license     = var.accept_aimanager_license
  accept_event_manager_license = var.accept_event_manager_license
  namespace                    = "aiops"
  enable_aimanager             = true

  //************************************
  // EVENT MANAGER OPTIONS START *******
  //************************************
  enable_event_manager         = true

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
}