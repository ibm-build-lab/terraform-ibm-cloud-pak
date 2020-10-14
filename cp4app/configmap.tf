resource "kubernetes_config_map" "icpa_kubeconfig" {
  count = var.enable ? 1 : 0

  depends_on = [
    kubernetes_namespace.icpa_installer_namespace
  ]

  metadata {
    name      = "icpa-kubeconfig"
    namespace = local.icpa_namespace
  }

  data = {
    config = file(var.cluster_config_path)
  }
}

resource "kubernetes_config_map" "icpa_config_data" {
  count = var.enable ? 1 : 0

  depends_on = [
    kubernetes_namespace.icpa_installer_namespace
  ]

  metadata {
    name      = "icpa-config-data"
    namespace = local.icpa_namespace
  }

  data = {
    "config.yaml"           = file("${path.module}/files/data/config.yaml")
    "kabanero.yaml"         = file("${path.module}/files/data/kabanero.yaml")
    "transadv.yaml"         = file("${path.module}/files/data/transadv.yaml")
    "mobilefoundation.yaml" = file("${path.module}/files/data/mobilefoundation.yaml")
  }
}
