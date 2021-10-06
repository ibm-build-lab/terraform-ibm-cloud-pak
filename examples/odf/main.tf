provider "ibm" {
  region = var.region
}

// Module:

module "odf" {
  source = "./.."
  // TODO: With Terraform 0.13 replace the parameter 'enable' or the conditional expression using 'with_iaf' with 'count'
  enable = var.enable
  cluster_id = var.cluster_id
  roks_version = var.roks_version

  // Cluster parameters
  //kube_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  kube_config_path = var.kube_config_path
}