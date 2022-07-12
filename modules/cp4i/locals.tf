
locals {
  entitled_registry      = "cp.icr.io"
  entitled_registry_user = "cp"
  entitled_registry_key  = chomp(var.entitled_registry_key)

  # These are the the yamls that will be pulled from the ./files. They will be used to start the operator
  catalog_content = templatefile("${path.module}/templates/catalog.yaml.tmpl", {
    namespace = var.namespace
  })
  subscription_content = templatefile("${path.module}/templates/subscription.yaml.tmpl", {
    namespace = var.namespace
  })
  navigator_content = templatefile("${path.module}/templates/navigator.yaml.tmpl", {
    namespace    = var.namespace
    storageclass = var.storageclass
  })
}

