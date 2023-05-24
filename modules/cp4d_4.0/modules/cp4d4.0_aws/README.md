# Terraform Module to install Cloud Pak for Data 4.0.x

### NOTE: This module has been deprecated and is no longer supported.

This Terraform Module installs **Cloud Pak for Data** on an Openshift cluster on AWS.

Based on [cpd-deployment](https://github.com/IBM/cp4d-deployment/tree/master/existing-openshift) opensource project.

**Module Source**: `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//cp4d_4.0/modules`

- [Terraform Module to install Cloud Pak for Data](#terraform-module-to-install-cloud-pak-for-data)
  - [Installing the CP4Data Module](#installing-the-cp4data-module)
  - [Input Variables](#input-variables)
  - [Executing the Terraform Script](#executing-the-terraform-script)
  - [Accessing the Cloud Pak Console](#accessing-the-cloud-pak-console)
  - [Clean up](#clean-up)
  - [Troubleshooting](#troubleshooting)
  

### Installing the CP4Data Module

Use a `module` block assigning `source` to `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//cp4d_4.0/modules/cp4data_4.0_aws`. Then set the [input variables](#input-variables) required to install the Cloud Pak for Data.

```hcl
module "cp4data" {
  source                    = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//cp4d_4.0/modules/cp4data_4.0_aws"
  openshift_api             = var.openshift_api
  openshift_username        = var.openshift_username
  openshift_password        = var.openshift_password
  openshift_token           = var.openshift_token
  login_cmd                 = var.login_cmd
  rosa_cluster              = var.rosa_cluster

  installer_workspace       = var.installer_workspace
  accept_cpd_license        = var.accept_cpd_license
  cpd_external_registry     = var.cpd_external_registry
  cpd_external_username     = var.cpd_external_username
  cpd_api_key               = var.cpd_api_key
  storage_option            = var.storage_option
  cpd_platform              = var.cpd_platform

  data_virtualization       = var.data_virtualization
  analytics_engine          = var.analytics_engine
  watson_knowledge_catalog  = var.watson_knowledge_catalog
  watson_studio             = var.watson_studio
  watson_machine_learning   = var.watson_machine_learning
  watson_ai_openscale       = var.watson_ai_openscale
  cognos_dashboard_embedded = var.cognos_dashboard_embedded
  datastage                 = var.datastage
  db2_warehouse             = var.db2_warehouse
  cognos_analytics          = var.cognos_analytics
  spss_modeler              = var.spss_modeler
  data_management_console   = var.data_management_console
  db2_oltp                  = var.db2_oltp
  master_data_management    = var.master_data_management
  db2_aaservice             = var.db2_aaservice
  decision_optimization     = var.decision_optimization
}
```


## Input Variables

| Name                               | Description                                                                                                                                                                                                                | Default                     | Required |
| ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------- | -------- |
| `openshift_api`                           | Openshift api url used by the cluster                              |                       | Yes       |
| `openshift_username`                           | Openshift username                                     |                       | Yes       |
| `openshift_password`                | Openshift password                |                        | Yes       | 
| `openshift_token`                | Openshift token (optional)               |                        | No       | 
| `openshift_login`                | Openshift login command ex. `oc login <url>`                |                        | Yes       | 
| `installer_workspace`                | The direct path to the workspace the TF templates will be placed.                |                        | Yes       | 
| `cpd_external_registry`                | URL to external registry for CPD install. Note: CPD images must already exist in the repo                |        `cp.icr.io`            | Yes       | 
| `cpd_external_username`                | URL to external username for CPD install. Note: CPD images must already exist in the repo                |        `cp`                | Yes       | 
| `cpd_api_key`            | Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key |                             | Yes      |
| `storage_option`     | Define the storage option. For now it's `portworx`                                                                                                    |         `portworx`                    | Yes      |
| `accept_cpd_license`          | If set to `accept`, you accept all cpd license agreements including additional modules installed. By default, it's `decline` | `decline` | Yes       |
| `watson_knowledge_catalog` | Install Watson Knowledge Catalog module. By default it's not installed.                                                                                                                                                    | `{ "enable" : "no", "version" : "4.0.1", "channel" : "v1.0" }`                     | No       |
| `watson_studio`            | Install Watson Studio module. By default it's not installed.                                                                                                                                                               | `{ "enable" : "no", "version" : "4.0.1", "channel" : "v2.0" }`                     | No       |
| `watson_machine_learning`  | Install Watson Machine Learning module. By default it's not installed.                                                                                                                                                     | `{ "enable" : "no", "version" : "4.0.1", "channel" : "v1.1" }`                     | No       |
| `watson_ai_openscale`        | Install Watson Open Scale module. By default it's not installed.                                                                                                                                                           | `{ "enable" : "no", "version" : "4.0.1", "channel" : "v1" }`                     | No       |
| `data_virtualization`      | Install Data Virtualization module. By default it's not installed.                                                                                                                                                         | `{ "enable" : "no", "version" : "1.7.1", "channel" : "v1.7" }`                     | No       |
| `spss_modeler`                  | Install SPSS modeler module. By default it's not installed.                                                                                                                                                                     | `{ "enable" : "no", "version" : "4.0.1", "channel" : "v1.0" }`                     | No       |
| `cognos_dashboard_embedded`      | Install Cognos Dashboard module. By default it's not installed.                                                                                                                                                         | `{ "enable" : "no", "version" : "4.0.1", "channel" : "v1.0" }`                     | No       |
| `analytics_engine`                    | Install Analytics Engine powered by Apache Spark module. By default it's not installed.                                                                                                                                    | `{ "enable" : "no", "version" : "4.0.1", "channel" : "stable-v1" }`                     | No       |
| `db2_warehouse`            | Install DB2 Warehouse module. By default it's not installed.                                                                                                                                                               | `{ "enable" : "no", "version" : "4.0.1", "channel" : "v1.0" }`                     | No       |
| `db2_oltp`            | Install DB2 OLTP module. By default it's not installed.                                                                                                                                                               | `{ "enable" : "no", "version" : "4.0.1", "channel" : "v1.0" }`                     | No       |
| `datastage`                  | Install Datastage module. By default it's not installed.                                                                                                                                                                     | `{ "enable" : "no", "version" : "4.0.1", "channel" : "v1.0" }`                     | No       |
| `cognos_analytics`                  | Install Cognos Analytics module. By default it's not installed.                                                                                                                                                                     | `{ "enable" : "no", "version" : "4.0.1", "channel" : "v4.0" }`                     | No       |
| `master_data_management`      | Install Master Data Management module. By default it's not installed.                                                                                                                                                         | `{ "enable" : "no", "version" : "4.0.1", "channel" : "v1.1" }`                     | No       |
| `decision_optimization`      | Install Decision Optimization module. By default it's not installed.                                                                                                                                                         | `{ "enable" : "no", "version" : "4.0.1", "channel" : "v4.0" }`                     | No       |


For an example of how to put all this together, refer to our [Cloud Pak for Data Terraform script](https://github.com/ibm-build-lab/cloud-pak-sandboxes/tree/master/terraform/cp4data).

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
kubectl get route -n zen cpd -o json | jq -r .spec.host && echo
```

To get default login id: `admin`

To get default Password:

```bash
kubectl -n zen get secret admin-user-details -o jsonpath='{.data.initial_admin_password}' | base64 -d && echo
```

## Clean up

When you finish using the cluster, release the resources by executing the following command:

```bash
terraform destroy
```
