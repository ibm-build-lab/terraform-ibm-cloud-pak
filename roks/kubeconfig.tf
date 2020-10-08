resource "null_resource" "mkdir_config_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "[[ '${var.download_config}' == 'true' ]] && mkdir -p ${var.config_dir}"
  }
}

// The local_cluster_config store the kubeconfig in the local filesystem for the
// local-exec with kubectl to use it
data "ibm_container_cluster_config" "cluster_config" {
  depends_on = [null_resource.mkdir_config_dir]

  cluster_name_id   = local.cluster_name_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = var.download_config
  config_dir        = var.config_dir
  admin             = var.config_admin
  network           = var.config_network
}
