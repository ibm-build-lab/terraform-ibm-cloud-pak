provider "ibm" {
  region           = var.region
  version          = "~> 1.12"
  ibmcloud_api_key = var.ibmcloud_api_key
}


data "ibm_resource_group" "group" {
  name = var.resource_group
}

# go in the example
resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
  provisioner "local-exec" {
    command = "mkdir -p ${var.kube_config_path}"
  }
}

data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]
  cluster_name_id   = var.cluster_name_or_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = true
  config_dir        = ".kube/config"
  admin             = false
  network           = false
}

resource "null_resource" "setting_platform" {
  provisioner "local-exec" {
    command = "/bin/bash ./scripts/cp4ba-clusteradmin-install.sh"

    environment = {
      # Cluster
      CLUSTER_NAME_OR_ID     = var.cluster_name_or_id
    //    on_vpc              = var.on_vpc

        // IBM Cloud API Key
      IBMCLOUD_API_KEY = var.ibmcloud_api_key

      # Cluster
  //    on_vpc                        = var.on_vpc
  //    portworx_is_ready             = var.portworx_is_ready
  //    namespace                     = local.cp4ba_namespace
  //
  //    # Platform
      PLATFORM_SELECTED              = local.platform_options
      PLATFORM_VERSION              = local.platform_version
      PROJECT_NAME                     = local.project_name
      DEPLOYMENT_TYPE               = local.deployment_type
      RUNTIME_MODE                  = local.runtime_mode
      USER_NAME_EMAIL                = var.entitled_registry_user_email
      USE_ENTITLEMENT               = local.use_entitlement
      ENTITLED_REGISTRY_KEY               = var.entitlement_key # file("${path.cwd}/../../entitlement.key")
      # Registry Images
      ENTITLED_REGISTRY_KEY_SECRET_NAME = local.entitled_registry_key_secret_name
      DOCKER_SERVER                 = local.docker_server
      DOCKER_USERNAME               = local.docker_username
      DOCKER_USER_EMAIL                  = local.docker_email
      public_registry_server        = var.public_registry_server
      LOCAL_PUBLIC_REGISTRY_SERVER   = var.public_image_registry
      machine  = local.machine
  //    local_registry_server         = var.registry_server
  //    local_registry_user           = var.registry_user

      # ------- CP4BA SETTINGS --------
      CP4BA_ADMIN_NAME = local.cp4ba_admin_name
      CP4BA_ADMIN_GROUP = local.cp4ba_admin_group
      CP4BA_USERS_GROUP = local.cp4ba_users_group
      CP4BA_UMS_ADMIN_NAME = local.cp4ba_ums_admin_name
      CP4BA_UMS_ADMIN_GROUP = local.cp4ba_ums_admin_group
      CP4BA_OCP_HOSTNAME = var.cp4ba_ocp_hostname
      CP4BA_TLS_SECRET_NAME = var.cp4ba_tls_secret_name
      CP4BA_ADMIN_PASSWORD = var.cp4ba_admin_password
      CP4BA_UMS_ADMIN_PASSWORD = var.cp4ba_ums_admin_password

  //    # Storage Classes
      STORAGE_CLASSNAME            = local.storage_class_name
      SC_SLOW_FILE_STORAGE_CLASSNAME   = local.sc_slow_file_storage_classname
      SC_MEDIUM_FILE_STORAGE_CLASSNAME = local.sc_medium_file_storage_classname
      SC_FAST_FILE_STORAGE_CLASSNAME   = local.sc_fast_file_storage_classname
    }
  }

  provisioner "local-exec" {
  command = "/bin/bash ./scripts/cp4ba-post-deployment.sh"

//    environment = {
//      # Cluster
//      CLUSTER_NAME_OR_ID     = var.cluster_name_or_id

//    }
  }


  # --------------- PROVISION DB2  ------------------
  provisioner "create_db2_on_ocp" {
    command = "/bin/bash ./deployment-db2-cp4ba/03_create_Db2_on_OCP.sh"

    environment {
      # CP4BA Database Name information
      DB2_UMS_DB_NAME       = local.db2_ums_db_name
      DB2_ICN_DB_NAME       = local.db2_icn_db_name
      DB2_DEVOS_1_NAME      = local.db2_devos_1_name
      DB2_AEOS_NAME         = local.db2_aeos_name
      DB2_BAW_DOCS_NAME     = local.db2_baw_docs_name
      DB2_BAW_TOS_NAME      = local.db2_baw_tos_name
      DB2_BAW_DOS_NAME      = local.db2_baw_dos_name
      DB2_BAW_DB_NAME       = local.db2_baw_Db_name
      DB2_APP_DB_NAME       = local.db2_app_db_name
      DB2_AE_DB_NAME        = local.db2_ae_db_name
      DB2_BAS_DB_NAME       = local.db2_bas_db_name
      DB2_GCD_DB_NAME       = local.db2_gcd_db_name
      DB2_ON_OCP_PROJECT_NAME  = local.db2_on_ocp_project_name
      DB2_ADMIN_USER_PASSWORD  = local.db2_admin_user_password
      DB2_STANDARD_LICENSE_KEY = local.db2_standard_license_key
      DB2_CPU                  = local.db2_cpu
      DB2_MEMORY               = local.db2_memory
      DB2_INSTANCE_VERSION     = local.db2_instance_version
      DB2_HOST_NAME            = local.db2_host_name
      DB2_HOST_IP              = local.db2_host_ip
      DB2_PORT_NUMBER          = local.db2_port_number
      DB2_USE_ONN_OCP          = local.db2_use_on_ocp
      DB2_ADMIN_USER_NAME      = local.db2_admin_user_name
      CP4BA_DEPLOYMENT_PLATFORM = local.cp4ba_deployment_platform
      DB2_ON_OCP_STORAGE_CLASS_NAME = local.db2_on_ocp_storage_class_name
      DB2_STORAGE_SIZE          = local.db2_storage_size
      # ------ Docker Information ----------
      ENTITLED_REGISTRY_KEY     = var.entitlement_key
      DOCKER_USER_EMAIL         = local.docker_email
      DOCKER_SERVER             = local.docker_server
      DOCKER_USERNAME           = local.docker_username
    }
  }

  # ---------------- LDAP PROVISION --------------------
  provisioner "create_ldap" {
    command = "/bin/bash ./deployment-db2-cp4ba/install_ldap.sh"

    environment = {
      # ------- LDAP SETTINGS ----------
      LDAP_NAME = local.ldap_name
      LDAP_ADMIN_NAME = local.ldap_admin_name
      LDAP_TYPE = local.ldap_type
      LDAP_SERVER = var.ldap_server
      LDAP_ADMIN_PASSWORD = var.ldap_admin_password
      LDAP_PORT = local.ldap_port
      LDAP_BASE_DN = local.ldap_base_dn
      LDAP_USER_NAME_ATTRIBUTE = local.ldap_user_name_attribute
      LDAP_USER_DISPLAY_NAME_ATTR = local.ldap_user_display_name_attr
      LDAP_GROUP_BASE_DN = local.ldap_group_base_dn
      LDAP_GROUP_NAME_ATTRIBUTE = local.ldap_group_name_attribute
      LDAP_GROUP_DISPLAY_NAME_ATTR = local.ldap_group_display_name_attr
      LDAP_GROUP_MEMBERSHIP_SEARCH_FILTER = local.ldap_group_membership_search_filter
      LDAP_GROUP_MEMBER_ID_IP = local.ldap_group_member_id_map
      LDAP_AD_GC_HOST = local.ldap_ad_gc_host
      LDAP_AD_GC_PORT = local.ldap_ad_gc_port
      LDAP_AD_USER_FILTER = local.ldap_ad_user_filter
      LDAP_AD_GROUP_FILTER = local.ldap_ad_group_filter
      LDAP_TDS_USER_FILTER = local.ldap_tds_user_filter
      LDAP_TDS_GROUP_FILTER = local.ldap_tds_group_filter

      # --- HA Settings ---
      CP4BA_REPLICA_COUNT = local.cp4ba_replica_count
      CP4BA_BAI_JOB_PARALLELISM = local.cp4ba_bai_job_parallelism
    }
  }
}