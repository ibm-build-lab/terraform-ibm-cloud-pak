locals {
  catalogsource_content = templatefile("../templates/CatalogSource.yaml.tmpl", {
  })

  AutomationBase = templatefile("../templates/AutomationBase.yaml.tmpl", {
    namespace                = "iaf",
  })

  subscription_content = templatefile("../templates/Subscription.yaml.tmpl", {
    namespace                = "iaf",
  })
}

resource "local_file" "CatalogSource" {
  content  = local.catalogsource_content
  filename = "${path.module}/rendered_files/CatalogSource.yaml"
}

resource "local_file" "AutomationBase" {
  content  = local.AutomationBase
  filename = "${path.module}/rendered_files/AutomationBase.yaml"
}

resource "local_file" "Subscription" {
  content  = local.subscription_content
  filename = "${path.module}/rendered_files/Subscription.yaml"
}


