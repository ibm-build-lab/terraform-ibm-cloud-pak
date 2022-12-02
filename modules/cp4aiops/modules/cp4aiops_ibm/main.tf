locals {
  on_vpc_ready = var.on_vpc ? var.portworx_is_ready : 1

  # TODO, add additional aiops features from default
  storageclass = {
    "ldap"        = var.on_vpc ? "portworx-aiops" : "ibmc-file-gold-gid",
    "persistence" = var.on_vpc ? "portworx-aiops" : "ibmc-file-gold-gid",
    # "zen"         = var.on_vpc ? "portworx-aiops" : "ibmc-file-gold-gid",
    "topology"    = var.on_vpc ? "portworx-aiops" : "ibmc-file-gold-gid"
  }
}

###########################################
# Installation Steps for AIOPS - AIManager
###########################################

resource "null_resource" "install_aiops_operator" {
  count = var.enable_aimanager ? 1 : 0
  depends_on = [
    local.on_vpc_ready,
    null_resource.prereqs_checkpoint
  ]

  provisioner "local-exec" {
    command     = "./install_aiops_operator.sh"
    working_dir = "${path.module}/scripts/aimanager/"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.namespace
    }
  }
}

resource "null_resource" "install_cp4aiops" {
  depends_on = [
    null_resource.install_aiops_operator
  ]
  
  triggers = {
    namespace_sha1                      = sha1(var.namespace)
    docker_params_sha1                  = sha1(join("", [var.entitled_registry_user_email, local.entitled_registry_key]))
  }

  provisioner "local-exec" {
    command     = "./install_cp4aiops.sh"
    working_dir = "${path.module}/scripts/aimanager/"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.namespace
      ACCEPT_LICENSE                = var.accept_aimanager_license
      ON_VPC                        = var.on_vpc
      DOCKER_REGISTRY_PASS          = var.entitled_registry_key
      DOCKER_USER_EMAIL             = var.entitled_registry_user_email
      DOCKER_USERNAME               = local.docker_username
      DOCKER_REGISTRY               = local.docker_registry
    }
  }
}

resource "null_resource" "configure_cert_nginx" {
  count = var.enable ? 1 : 0

  depends_on = [
    null_resource.install_cp4aiops
  ]

  provisioner "local-exec" {
    command     = "./update_cert.sh"
    working_dir = "${path.module}/scripts/aimanager"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.namespace
    }
  }
}

###########################################
# Installation Steps for AIOPS - EventManager
###########################################

resource "null_resource" "install_event_manager_operator" {
  count = var.enable_event_manager ? 1 : 0
  depends_on = [
    local.on_vpc_ready,
    null_resource.prereqs_checkpoint,
    null_resource.configure_cert_nginx
  ]

  provisioner "local-exec" {
    command     = "./install_noi_operator.sh"
    working_dir = "${path.module}/scripts/eventmanager/"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.namespace
    }
  }
}

resource "null_resource" "install_event_manager" {

  provisioner "local-exec" {
    command     = "./install_event_manager.sh"
    working_dir = "${path.module}/scripts/eventmanager/"

    environment = {
      KUBECONFIG                    = var.cluster_config_path
      NAMESPACE                     = var.namespace
      ACCEPT_LICENSE                = var.accept_event_manager_license
      
      ENABLE_PERSISTENCE            = var.enable_persistence
      PERSISTENT_SC                 = local.storageclass["persistence"]
      
      HUMIO_REPO                    = var.humio_repo
      HUMIO_URL                     = var.humio_url
      
      LDAP_PORT                     = var.ldap_port
      LDAP_MODE                     = var.ldap_mode
      LDAP_SC                       = local.storageclass["ldap"]
      LDAP_USER_FILTER              = var.ldap_user_filter
      LDAP_BIND_DN                  = var.ldap_bind_dn
      LDAP_SSL_PORT                 = var.ldap_ssl_port
      LDAP_URL                      = var.ldap_url
      LDAP_SUFFIX                   = var.ldap_suffix
      LDAP_GROUP_FILTER             = var.ldap_group_filter
      LDAP_BASE_DN                  = var.ldap_base_dn
      LDAP_SERVER_TYPE              = var.ldap_server_type

      CAC                           = var.continuous_analytics_correlation
      BACKUP_DEPLOYMENT             = var.backup_deployment

      ENABLE_ZEN_DEPLOY             = var.zen_deploy
      ENABLE_ZEN_IGNORE_READY       = var.zen_ignore_ready
      ZEN_INSTANCE_NAME             = var.zen_instance_name
      ZEN_INSTANCE_ID               = var.zen_instance_id
      ZEN_INSTANCE_ID               = var.zen_namespace
      ZEN_STORAGE                   = var.zen_storage

      ENABLE_APP_DISC               = var.enable_app_discovery
      AP_CERT_SECRET                = var.ap_cert_secret
      AP_DB_SECRET                  = var.ap_db_secret
      AP_DB_HOST_URL                  = var.ap_db_host_url
      AP_SECURE_DB                  = var.ap_secure_db

      TOPOLOGY_SC                   = local.storageclass["topology"]
      ENABLE_NETWORK_DISCOVERY      = var.enable_network_discovery

      OBV_DOCKER                    = var.obv_docker
      OBV_TADDM                     = var.obv_taddm
      OBV_SERVICENOW                = var.obv_servicenow
      OBV_IBMCLOUD                  = var.obv_ibmcloud
      OBV_ALM                       = var.obv_alm
      OBV_CONTRAIL                  = var.obv_contrail
      OBV_CIENABLUEPLANET           = var.obv_cienablueplanet
      OBV_KUBERNETES                = var.obv_kubernetes
      OBV_BIGFIXINVENTORY           = var.obv_bigfixinventory
      OBV_JUNIPERCSO                = var.obv_junipercso
      OBV_DNS                       = var.obv_dns
      OBV_ITNM                      = var.obv_itnm
      OBV_ANSIBLEAWX                = var.obv_ansibleawx
      OBV_CISCOACI                  = var.obv_ciscoaci
      OBV_AZURE                     = var.obv_azure
      OBV_RANCHER                   = var.obv_rancher
      OBV_NEWRELIC                  = var.obv_newrelic
      OBV_VMVCENTER                 = var.obv_vmvcenter
      OBV_REST                      = var.obv_rest
      OBV_APPDYNAMICS               = var.obv_appdynamics
      OBV_JENKINS                   = var.obv_jenkins
      OBV_ZABBIX                    = var.obv_zabbix
      OBV_FILE                      = var.obv_file
      OBV_GOOGLECLOUD               = var.obv_googlecloud
      OBV_DYNATRACE                 = var.obv_dynatrace
      OBV_AWS                       = var.obv_aws
      OBV_OPENSTACK                 = var.obv_openstack
      OBV_VMWARENSX                 = var.obv_vmwarensx

      ENABLE_BACKUP_RESTORE         = var.enable_backup_restore
    }
  }

  depends_on = [
    null_resource.install_event_manager_operator
  ]
}

data "external" "get_aiman_endpoints" {
  depends_on = [
    null_resource.configure_cert_nginx,
    null_resource.install_event_manager
  ]

  program = ["/bin/bash", "${path.module}/scripts/aimanager/aimanager_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.namespace
  }
}

data "external" "get_evtman_endpoints" {
  depends_on = [
    null_resource.configure_cert_nginx,
    null_resource.install_event_manager
  ]

  program = ["/bin/bash", "${path.module}/scripts/eventmanager/eventmanager_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
    namespace  = var.namespace
  }
}
