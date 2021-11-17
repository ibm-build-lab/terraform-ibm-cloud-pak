# Terraform Module to install Cloud Pak for Data

This Terraform Module installs **Cloud Pak for Data** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git/modules/cp4data`

- [Terraform Module to install Cloud Pak for Data](#terraform-module-to-install-cloud-pak-for-data)
  - [Set up access to IBM Cloud](#set-up-access-to-ibm-cloud)
  - [Provisioning this module in a Terraform Script](#provisioning-this-module-in-a-terraform-script)
    - [Setting up the OpenShift cluster](#setting-up-the-openshift-cluster)
    - [Installing the CP4Data Module](#installing-the-cp4data-module)
  - [Input Variables](#input-variables)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Accessing the Cloud Pak Console](#accessing-the-cloud-pak-console)
  - [Clean up](#clean-up)
  - [Troubleshooting](#troubleshooting)
  

## Provisioning this module in a Terraform Script

In your Terraform code define the `aws` provisioner block with the `region` and the `generation`, which is **1 for Classic** and **2 for VPC Gen 2**.

```hcl
provider "aws" {
  region     = var.region
  access_key = var.access_key_id
  secret_key = var.secret_access_key
}
```

**NOTE**: Create the `./kube/config` directory if it doesn't exist.

Run the following command to create the config file prior to running this module: `touch .kube/config && KUBECONFIG=.kube/config oc login --token=[YOUR TOKEN] --server=[YOUR SERVER INFO]`

The token and server info can be found on this Openshift `copy login command` drop down.

### Installing the CP4Data Module

Use a `module` block assigning `source` to `github.com/ibm-hcbt/terraform-ibm-cloud-pak.git//cp4data`. Then set the [input variables](#input-variables) required to install the Cloud Pak for Data.

```hcl
module "cp4data" {
  source          = "./.."
  enable          = var.enable

  // ROKS cluster parameters:
  openshift_version   = var.openshift_version
  cluster_config_path = var.cluster_config_path
  on_vpc              = var.on_vpc
  portworx_is_ready   = var.portworx_is_ready // only need if on_vpc = true
  
  // Prereqs
  worker_node_flavor = var.worker_node_flavor

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key
  entitled_registry_user_email = var.entitled_registry_user_email

  // CP4D License Acceptance
  accept_cpd_license = var.accept_cpd_license

  // CP4D Info
  cpd_project_name = var.cpd_project_name

  // Parameters to install submodules
  install_watson_knowledge_catalog = var.install_watson_knowledge_catalog
  install_watson_studio            = var.install_watson_studio
  install_watson_machine_learning  = var.install_watson_machine_learning
  install_watson_open_scale        = var.install_watson_open_scale
  install_data_virtualization      = var.install_data_virtualization
  install_streams                  = var.install_streams
  install_analytics_dashboard      = var.install_analytics_dashboard
  install_spark                    = var.install_spark
  install_db2_warehouse            = var.install_db2_warehouse
  install_db2_data_gate            = var.install_db2_data_gate
  install_big_sql                  = var.install_big_sql
  install_rstudio                  = var.install_rstudio
  install_db2_data_management      = var.install_db2_data_management
}
```



- 

## Input Variables

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `enable`                           | If set to `false` does not install the cloud pak on the given cluster. By default it's enabled                                                                                                                        | `true`                      | No       |
| `on_vpc`                           | If set to `false`, it will set the install do classic ROKS. By default it's disabled                                                                                                                        | `false`                      | No       |
| `openshift_version`                | Openshift version installed in the cluster                                                                                                                                                                                 | `4.6`                       | No       |
| `entitled_registry_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `entitled_registry_user_email`     | IBM Container Registry (ICR) username which is the email address of the owner of the Entitled Registry Key                                                                                                                 |                             | Yes      |
| `worker_node_flavor`          | Flavor used to determine worker node hardware for the cluster |  | Yes       |
| `accept_cpd_license`          | If set to `true`, you accept all cpd license agreements including additional modules installed. By default, it's `false` | `false` | Yes       |
| `install_watson_knowledge_catalog` | Install Watson Knowledge Catalog module. By default it's not installed.                                                                                                                                                    | `false`                     | No       |
| `install_watson_studio`            | Install Watson Studio module. By default it's not installed.                                                                                                                                                               | `false`                     | No       |
| `install_watson_machine_learning`  | Install Watson Machine Learning module. By default it's not installed.                                                                                                                                                     | `false`                     | No       |
| `install_watson_open_scale`        | Install Watson Open Scale module. By default it's not installed.                                                                                                                                                           | `false`                     | No       |
| `install_data_virtualization`      | Install Data Virtualization module. By default it's not installed.                                                                                                                                                         | `false`                     | No       |
| `install_streams`                  | Install Streams module. By default it's not installed.                                                                                                                                                                     | `false`                     | No       |
| `install_analytics_dashboard`      | Install Analytics Dashboard module. By default it's not installed.                                                                                                                                                         | `false`                     | No       |
| `install_spark`                    | Install Analytics Engine powered by Apache Spark module. By default it's not installed.                                                                                                                                    | `false`                     | No       |
| `install_db2_warehouse`            | Install DB2 Warehouse module. By default it's not installed.                                                                                                                                                               | `false`                     | No       |
| `install_db2_data_gate`            | Install DB2 Data_Gate module. By default it's not installed.                                                                                                                                                               | `false`                     | No       |
| `install_big_sql`                  | Install Big SQL module. By default it's not installed.                                                                                                                                                                     | `false`                     | No       |
| `install_rstudio`                  | Install RStudio module. By default it's not installed.                                                                                                                                                                     | `false`                     | No       |
| `install_db2_data_management`      | Install DB2 Data Management module. By default it's not installed.                                                                                                                                                         | `false`                     | No       |

**NOTE** The boolean input variable `enable` is used to enable/disable the module. This parameter may be deprecated when Terraform 0.12 is not longer supported. In Terraform 0.13, the block parameter `count` can be used to define how many instances of the module are needed. If set to zero the module won't be created.

For an example of how to put all this together, refer to our [Cloud Pak for Data Terraform script](https://github.com/ibm-hcbt/cloud-pak-sandboxes/tree/master/terraform/cp4data).

## Executing the Terraform Script

Execute the following commands to install the Cloud Pak:

```bash
terraform init
terraform plan
terraform apply
```

## Accessing the Cloud Pak Console

After execution has completed, access the cluster using `kubectl` or `oc`:

```bash
ibmcloud oc cluster config -c <cluster-name> --admin
kubectl get route -n ibm-common-services cp-console -o jsonpath=‘{.spec.host}’ && echo
```

To get default login id:

```bash
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}\' | base64 -d && echo
```

To get default Password:

```bash
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d && echo
```

## Clean up

When you finish using the cluster, release the resources by executing the following command:

```bash
terraform destroy
```

## Troubleshooting

- Once `module.cpd_install.null_resource.install_cpd` completes. You can check the logs to find out more information about the installation of Cloud Pak for Data.

```bash
cpd-meta-operator: oc -n cpd-meta-ops logs -f deploy/ibm-cp-data-operator

cpd-install-operator: oc -n cpd-tenant logs -f deploy/cpd-install-operator
```
