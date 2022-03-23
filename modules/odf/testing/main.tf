provider "ibm" {
  region = var.region
}

// Module:

module "odf" {
  source = "./.."
  enable = var.enable
  cluster = var.cluster
  roks_version = var.roks_version

  // Cluster parameters
  //kube_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  kube_config_path = var.kube_config_path
}
