resource "null_resource" "mkdir_config_dir" {
  triggers = { always_run = timestamp() }

  provisioner "local-exec" {
    command = "if [[ '${var.download_config}' == 'true' && '${var.enable}' == 'true' ]]; then mkdir -p ${var.config_dir}; fi"
  }
}

// The local_cluster_config store the kubeconfig in the local filesystem for the
// local-exec with kubectl to use it
data "ibm_container_cluster_config" "cluster_config" {
  count      = var.enable ? 1 : 0
  depends_on = [null_resource.mkdir_config_dir]

  cluster_name_id   = local.cluster_name_id
  resource_group_id = data.ibm_resource_group.group.id
  download          = var.download_config
  config_dir        = var.download_config ? var.config_dir : null
  admin             = var.config_admin
  network           = var.config_network
}
