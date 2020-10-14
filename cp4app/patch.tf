resource "kubernetes_config_map" "icpa_patch" {
  count = var.enable ? 1 : 0

  depends_on = [
    kubernetes_namespace.icpa_installer_namespace
  ]

  metadata {
    name      = "icpa-patch"
    namespace = local.icpa_namespace
  }

  data = {
    "patch.sh" = <<EOF
#!/bin/bash

echo "Patching code to get the Tekton Dashboard route"
sed -i.back 's/oc get route tekton-dashboard/oc get route tekton-dashboard -n tekton-pipelines/' /installer/playbook/roles/tekton/tasks/install.yaml

echo "Patching code to get the Application Navigator UI route"
sed -i.back 's/oc get route kappnav-ui-service/oc get route kappnav-ui-service -n kappnav/' /installer/playbook/roles/appnav/tasks/install.yaml

EOF
  }
}
