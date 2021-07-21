provider "ibm" {
  region           = var.region
  version          = "~> 1.12.0"
  ibmcloud_api_key = var.ibmcloud_api_key
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}


module "cluster" {
  source = "../roks"
  // source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/roks"
  enable = local.enable_cluster
  on_vpc = var.on_vpc

  project_name             = var.project_name
  owner                    = var.entitled_registry_user_email
  environment              = var.environment
//  entitlement_registry_key = var.entitled_registry_key

  resource_group       = var.resource_group
  roks_version         = var.platform_version
  flavors              = var.flavors
  workers_count        = var.workers_count
  datacenter          = var.data_center
  force_delete_storage = true
  vpc_zone_names       = var.vpc_zone_names

  private_vlan_number  = var.private_vlan_number
  public_vlan_number   = var.public_vlan_number
}

# getting and creation a directory for the cluster config file
resource "null_resource" "mkdir_kubeconfig_dir" {
  triggers = { always_run = timestamp() }
    provisioner "local-exec" {
    command = "mkdir -p ${var.cluster_config_path}"
  }
}


data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_kubeconfig_dir]

  cluster_name_id      = local.enable_cluster ? module.cluster.id : var.cluster_name_id
  resource_group_id    = module.cluster.resource_group.id
  config_dir           = var.cluster_config_path
  download             = true
  admin                = false
  network              = false
}

resource "null_resource" "setting_platform" {

    provisioner "local-exec" {
    command = "mkdir -p ${var.cluster_config_path}"
  }

  provisioner "local-exec" {
    command = "/bin/bash ../scripts/cp4ba-clusteradmin-install.sh"

    environment = {
      Platform_Option = var.platform_options
      # == 1 var.platform_options : "ROKS"&& var.platform_options == 2 ? var.platform_options : 3
      Platform_Version = var.platform_version
      Project_Name = var.project_name
      Deployment_Type = var.deployment_type
      Username_Email = var.entitled_registry_user_email
      Use_Entitlement = local.use_entitlement
      Entitlement_Key = local.entitled_registry_key
      Local_Public_Registry_Server = local.local_public_registry_server
      Local_Public_Image_Registry = local.local_public_image_registry
      Local_Registry_Server = local.local_registry_server
      Local_Registry_User   = local.local_registry_user
      Local_Registry_Password = local.local_registry_password
      Storage_Class_Name = local.storage_class_name
      Sc_Slow_File_Storage_Classname = local.sc_slow_file_storage_classname
      Sc_Medium_File_Storage_Classname = local.sc_medium_file_storage_classname
      Sc_Fast_File_Storage_Classname = local.sc_fast_file_storage_classname
    }
  }
}


////######################### PORTWORX ##################################
module "portworx" {
  //  depends_on = [
//    null_resource.setting_platform
//  ]

  source = "../portworx"
//  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/portworx"
  // TODO: With Terraform 0.13 replace the parameter 'enable' or the conditional expression using with 'count'
  enable = var.install_portworx

  ibmcloud_api_key = var.ibmcloud_api_key

  // Cluster parameters
  kube_config_path = data.ibm_container_cluster_config.cluster_config.config_dir
  worker_nodes     = var.workers_count[0]  // Number of workers

  // Storage parameters
  install_storage      = true
  storage_capacity     = var.storage_capacity  // In GBs
  storage_profile      = var.storage_profile

  // Portworx parameters
  resource_group_name   = var.resource_group
  region                = var.region
  cluster_id            = data.ibm_container_cluster_config.cluster_config.cluster_name_id
  unique_id             = "px-roks-${data.ibm_container_cluster_config.cluster_config.cluster_name_id}"

  // These credentials have been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.
  // You may override these for additional security.
  create_external_etcd  = var.create_external_etcd
  etcd_username         = var.etcd_username
  etcd_password         = var.etcd_password

  // Defaulted.  Don't change
  etcd_secret_name      = "px-etcd-certs"
}

//######################### DB2 ##################################
//data "external" "install_db2" {
//
//  depends_on = [
//    null_resource.setting_platform
//  ]
//
//  program = [
//    "/bin/bash",
//    "../../scripts/install_db2_local.sh"]
//  //  program = ["/bin/bash", "${path.module}/scripts/install_db2_local.sh"]
//
//  query = {
//    kubeconfig = var.cluster_config_path
//    namespace = var.namespace
//  }
//}
//
//
////######################### LDAP ##################################
//module "ldap" {
//  source = "../../ldap"
////  source = "git::https://github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//modules/ldap"
//
//  ibmcloud_api_key      = var.ibmcloud_api_key
//  region                = var.region
//  iaas_classic_api_key  = var.iaas_classic_api_key
//  iaas_classic_username = var.iaas_classic_username
//  ssh_public_key_file   = var.ssh_public_key_file
//  ssh_private_key_file  = var.ssh_private_key_file
//  classic_datacenter    = var.classic_datacenter
//}
//
//






//data "ibm_container_cluster_config" "cluster_config" {
//  depends_on = [null_resource.mkdir_kubeconfig_dir]
//  cluster_name_id   = var.cluster_name_id
////  resource_group_id = var.resource_group.group.id
////  resource_group = var.resource_group
//  config_dir  = var.cluster_config_path
//}


