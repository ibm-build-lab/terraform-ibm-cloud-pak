provider "kubernetes" {
  config_path = var.cluster_config_path
}

resource "kubernetes_namespace" "icpa_installer_namespace" {
  count = var.enable ? 1 : 0

  metadata {
    name = local.icpa_namespace
  }

  timeouts {
    delete = "2h"
  }
}

resource "null_resource" "kubectl_create_secret" {
  count = var.enable ? 1 : 0

  depends_on = [
    kubernetes_namespace.icpa_installer_namespace,
  ]
  triggers = {
    docker_credentials_sha1 = sha1(join("", [local.entitled_registry_user, local.entitled_registry_key, var.entitled_registry_user_email, local.entitled_registry, local.icpa_namespace]))
  }

  // Ensure that the image registry has a valid route for IBM Cloud Pak for Multicloud Management images
  provisioner "local-exec" {
    command = "kubectl --kubeconfig ${var.cluster_config_path} patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{\"spec\":{\"defaultRoute\":true}}'"
  }

  // Create secret from entitlement key
  provisioner "local-exec" {
    command = "kubectl create secret docker-registry icpa-installer-pull-secret --docker-username=${local.entitled_registry_user} --docker-password=${local.entitled_registry_key} --docker-email=${var.entitled_registry_user_email} --docker-server=${local.entitled_registry} --namespace=${local.icpa_namespace} --dry-run=client -o yaml | kubectl apply -f -"
    environment = {
      KUBECONFIG = var.cluster_config_path
    }
  }
}

resource "kubernetes_job" "icpa_installer_job" {
  count = var.enable ? 1 : 0

  depends_on = [
    kubernetes_config_map.icpa_kubeconfig,
    kubernetes_config_map.icpa_config_data,
    null_resource.kubectl_create_secret,
  ]

  metadata {
    name      = "icpa-installer"
    namespace = local.icpa_namespace
  }
  spec {
    template {
      metadata {}
      spec {
        // security_context {
        //   run_as_user = 0
        // }
        volume {
          name = "patch-volume"
          config_map {
            name = "icpa-patch"
          }
        }
        volume {
          name = "config-data-volume"
          config_map {
            name = "icpa-config-data"
          }
        }
        volume {
          name = "kubeconfig-volume"
          config_map {
            name = "icpa-kubeconfig"
          }
        }
        container {
          name    = "icpa-installer"
          image   = "${local.entitled_registry}/${local.entitled_registry_user}/icpa/${local.icpa_installer_image}"
          command = ["/bin/sh"]
          args = [
            "-c",
            "/bin/bash /installer/scripts/extra/patch.sh && /installer/entrypoint.sh ${var.cp4app_installer_command}",
          ]
          // FIX: There is a bug in the icpa-installer container, this bug and its fix is documented at:
          // https://github.ibm.com/IBMCloudPak4Apps/icpa-install/issues/902
          // To fix it, the above 'patch.sh` script is mounted from a ConfigMap, then it is executed.
          // When the bug is fixed, remove the volume and volume_mount parameters for 'patch-volume',
          // the command parameter and replace the 'args' parameter for:
          //    args  = [ var.cp4app_installer_command ]

          // DEBUG: You can debug this job either (1) Viewing the logs or (2) Login into the container:
          // 1) Execute:
          //      pod=$(kubectl get pods --selector=job-name=icpa-installer -n icpa-installer --output=jsonpath='{.items[*].metadata.name}')
          //      kubectl logs -f -n icpa-installer $pod
          // 2) Change the command and args to:
          //      command = ["/bin/sh"]
          //      args = ["-c", "while true; do date; sleep 120;done"]
          //    Then, execute:
          //      pod=$(kubectl get pods --selector=job-name=icpa-installer -n icpa-installer --output=jsonpath='{.items[*].metadata.name}')
          //      kubectl exec --stdin --tty -n icpa-installer $pod -- /bin/bash
          resources {}

          volume_mount {
            name       = "patch-volume"
            mount_path = "/installer/scripts/extra"
          }
          volume_mount {
            name       = "config-data-volume"
            mount_path = "/data_from_terraform"
            // TODO: Change the mount_path to "/data" to use the generated ConfigMaps
          }
          volume_mount {
            name       = "kubeconfig-volume"
            mount_path = "/installer/.kube"
          }

          env {
            name  = "LICENSE"
            value = "accept"
          }
          env {
            name  = "KUBECONFIG"
            value = "/installer/.kube/config"
          }
          env {
            name  = "ENTITLED_REGISTRY"
            value = local.entitled_registry
          }
          env {
            name  = "ENTITLED_REGISTRY_USER"
            value = local.entitled_registry_user
          }
          env {
            name  = "ENTITLED_REGISTRY_KEY"
            value = local.entitled_registry_key
          }
        }
        image_pull_secrets {
          name = "icpa-installer-pull-secret"
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 1
  }

  wait_for_completion = true

  timeouts {
    create = "2h"
    update = "2h"
  }
}

data "external" "get_endpoints" {
  count = var.enable ? 1 : 0

  depends_on = [
    kubernetes_job.icpa_installer_job,
  ]

  program = ["/bin/bash", "${path.module}/scripts/get_endpoints.sh"]

  query = {
    kubeconfig = var.cluster_config_path
  }
}
