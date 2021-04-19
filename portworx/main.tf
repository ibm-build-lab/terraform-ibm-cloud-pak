# Licensed Source of IBM Copyright IBM Corp. 2020, 2021
data ibm_resource_group group {
  name = var.resource_group_name
}

data ibm_container_vpc_cluster this{
  name = var.cluster_name
  resource_group_id = data.ibm_resource_group.group.id
}

# data ibm_database ds {
#   name = local.etcd_custer_name
#   location = var.dc_region
#   resource_group_id = data.ibm_resource_group.group.id
# }

locals {
px_service_name      = "${var.base_name}-portworx"
px_storage_cluster   = "${var.base_name}-px-storage-cluster"
# etcd_custer_name = "${var.base_name}-etcd"
# etcd_endpoint = "etcd:https://${data.ibm_database.ds.connectionstrings[0].hosts[0].hostname}:${data.ibm_database.ds.connectionstrings[0].hosts[0].port}"
}

resource "null_resource" "create_storage" {
  count = var.enable && var.install_storage ? 1 : 0

  provisioner "local-exec" {
    command     = "./install_portworx_storage.sh"
    working_dir = "${path.module}/scripts"

    environment = {
      # IAM_TOKEN        = var.iam_token
      RESOURCE_GROUP   = var.resource_group_name
      VPC_REGION       = var.dc_region
      CLUSTER          = var.cluster_name
      STORAGE_REGION   = var.storage_region
      STORAGE_CAPACITY = var.storage_capacity
    }
  }
}

resource "ibm_resource_instance" "portworx_instance" {
  count = var.enable ? 1 : 0
  name              = local.px_service_name
  location          = var.dc_region # "us-south", "us-east", "eu-gb", "eu-de", "jp-tok", "au-syd", etc..
  resource_group_id = data.ibm_resource_group.group.id
  service           = "portworx"
  plan              = var.plan # "px-dr-enterprise", "px-enterprise"
  tags              = var.px_tags

  parameters = {
    apikey = var.ibmcloud_api_key
    clusters = data.ibm_container_vpc_cluster.this.id
    cluster_name = local.px_storage_cluster
    internal_kvdb = var.kvdb # "external", "internal"
    # etcd_endpoint = local.etcd_endpoint
    # etcd_secret = var.etcd_secret
    secret_type =  var.secret_type # "ibm-kp", "k8s"
    # adv_opts
    # portworx_version
  }

}