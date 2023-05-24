# Terraform Module to install Cloud Pak for Multi Cloud Management

### NOTE: This module has been deprecated and is no longer supported.


This Terraform Module installs the **Multi Cloud Management Cloud Pak** on an Openshift (ROKS) cluster on AWS.

**Module Source**: `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4mcm_aws`

- [Terraform Module to install Cloud Pak for Multi Cloud Management](#terraform-module-to-install-cloud-pak-for-multi-cloud-management)
  
  - [Set Cloud Pak Entitlement Key](#set-cloud-pak-entitlement-key)
  - [Installing the CP4MCM Module](#provisioning-the-CP4MCM-module)
  - [Input Variables](#input-variables)
  - [Testing](#testing)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Output Variables](#output-variables)
  - [Accessing the Cloud Pak Console](#accessing-the-cloud-pak-console)
  - [Clean up](#clean-up)


### Set Cloud Pak Entitlement Key

This module also requires an Entitlement Key. Obtain it [here](https://myibm.ibm.com/products-services/containerlibrary) and store it in the file `entitlement.key` in the root of this repository. If you use that filename, the file won't be published to GitHub if you accidentally push to GitHub. 

### Provisioning the CP4MCM Module

**NOTE**: Create the `./kube/config` directory if it doesn't exist.

Use a `module` block assigning `source` to `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4mcm_aws`. Then set the [input variables](#input-variables) required to install the Cloud Pak for Multi Cloud Management and submodules.

```hcl
module "cp4mcm" {
  source = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4mcm_aws"
  enable = true

  // ROKS cluster parameters:
  openshift_version   = local.roks_version
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path

  entitled_registry_key        = file("${path.cwd}/entitlement.key")
  entitled_registry_user_email = var.entitled_registry_user_email

  install_infr_mgt_module      = false
  install_monitoring_module    = false
  install_security_svcs_module = false
  install_operations_module    = false
  install_tech_prev_module     = false
}
```

## Input Variables

| Name                           | Description                                                                                                                                                                                                                | Default | Required |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `enable`                       | If set to `false` does not install the cloud pak on the given cluster. Enabled by default                                                                                                      | `true`  | No       |
| `cluster_config_path`          | The path on your local machine where the cluster configuration file and certificates are downloaded to                                                                                                                     |         | Yes      |
| `openshift_version`            | Openshift version installed in the cluster                                                                                                                                                                                 |         | Yes      |
| `entitled_registry_key`        | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |         | Yes      |
| `entitled_registry_user_email` | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |         | Yes      |
| `install_infr_mgt_module`      | Install the Infrastructure Management module                                                                                                                                                                               | `false` | No       |
| `install_monitoring_module`    | Install the Monitoring module                                                                                                                                                                                              | `false` | No       |
| `install_security_svcs_module` | Install the Security Services module                                                                                                                                                                                       | `false` | No       |
| `install_operations_module`    | Install the Operations module                                                                                                                                                                                              | `false` | No       |
| `install_tech_prev_module`     | Install the Tech Preview module                                                                                                                                                                                            | `false` | No       |

**NOTE** The boolean input variable `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.

For an example of how to put all this together, refer to our [Cloud Pak for Multi Cloud Management Terraform script](https://github.com/ibm-build-lab/cloud-pak-sandboxes/tree/master/terraform/cp4mcm).

## Testing

To manually run a module test before committing the code:

- go to the `testing` subdirectory
- follow instructions [here](testing/README.md)

The testing code provides an example of how to use the module.

## Executing the Terraform Script

Run the following commands to execute the TF script (containing the modules to create/use ROKS and Cloud Pak). Execution may take about 30 minutes:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Output Variables

Once the Terraform execution completes, use the following output variables to access CP4MCM Dashboard:

| Name        | Description                                                     |
| ----------- | --------------------------------------------------------------- |
| `endpoint`  | URL of the dashboard                                     |
| `user`      | Username to log in to the dashboard                       |
| `password`  | Password to log in to the dashboard                       |
| `namespace` | Kubernetes namespace where all the componenents are installed |

## Accessing the Cloud Pak Console

After execution has completed, access the cluster using `kubectl` or `oc`:

```bash
ibmcloud ks cluster config -cluster $(terraform output cluster_id)
kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output namespace)

# All resources
kubectl get all --namespace $(terraform output namespace)
```

Then, using the following credentials you can open the dashboard in a browser using the `endpoint` output parameter as URL.

```bash
terraform output user
terraform output password

open "http://$(terraform output endpoint)"
```

## Clean up

To clean up or remove CP4MCM and its dependencies from a cluster, execute the following commands:

```bash
kubectl delete -n openshift-operators subscription.operators.coreos.com ibm-management-orchestrator
kubectl delete -n openshift-marketplace catalogsource.operators.coreos.com ibm-management-orchestrator opencloud-operators
kubectl delete namespace cp4mcm
```

**Note**: The uninstall/cleanup up process is a work in progress at this time, we are identifying the objects that need to be deleted in order to have a successfully re-installation. This process will be included in the Terraform code.

When you finish using the cluster, you can release the resources executing the following command, it should finish in about _8 minutes_:

```bash
terraform destroy
```




