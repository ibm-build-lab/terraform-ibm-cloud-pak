resource "ibm_resource_instance" "cos" {
  count    = var.on_vpc ? 1 : 0
  name     = "${var.project_name}-${var.environment}-cos"
  service  = "cloud-object-storage"
  plan     = "standard"
  location = "global"
}

resource "ibm_container_vpc_cluster" "cluster" {
  count             = var.on_vpc ? 1 : 0
  name              = "${var.project_name}-${var.environment}-cluster"
  vpc_id            = var.on_vpc ? ibm_is_vpc.vpc[0].id : 0
  flavor            = var.flavors[0]
  worker_count      = var.workers_count[0]
  kube_version      = local.roks_version
  resource_group_id = data.ibm_resource_group.group.id
  cos_instance_crn  = ibm_resource_instance.cos[0].id
  wait_till         = "OneWorkerNodeReady"
  entitlement       = "cloud_pak"

  zones {
    name      = var.vpc_zone_names[0]
    subnet_id = ibm_is_subnet.subnet[0].id
  }

  tags = [
    "project:${var.project_name}",
    "env:${var.environment}",
    "owner:${var.owner}"
  ]
}

resource "ibm_container_vpc_worker_pool" "cluster_pool" {
  count             = var.on_vpc ? local.max_size - 1 : 0
  cluster           = var.on_vpc ? ibm_container_vpc_cluster.cluster[0].id : 0
  worker_pool_name  = "${var.project_name}-${var.environment}-wp-${format("%02s", count.index + 1)}"
  flavor            = var.flavors[count.index + 1]
  vpc_id            = ibm_is_vpc.vpc[0].id
  worker_count      = var.workers_count[count.index + 1]
  resource_group_id = data.ibm_resource_group.group.id
  zones {
    name      = var.vpc_zone_names[count.index + 1]
    subnet_id = ibm_is_subnet.subnet[count.index + 1].id
  }
}
