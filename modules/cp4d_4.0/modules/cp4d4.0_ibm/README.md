# Terraform Module to install Cloud Pak for Data

### NOTE: This module has been deprecated and is no longer supported.

This Terraform Module installs **Cloud Pak for Data** 4.0 on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4data_4.0/modules/cp4d4.0_ibm`

**NOTE:** an OpenShift cluster is required to install the Cloud Pak. This can be an existing cluster or can be provisioned using our [roks](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/roks) Terraform module.

The recommended size for an OpenShift 4.10+ cluster on IBM Cloud Classic contains `4` workers of flavor `b3c.16x64`, however read the [Cloud Pak for Data documentation](https://www.ibm.com/docs/en/cloud-paks/cp-data) to confirm these parameters or if you are using IBM Cloud VPC or a different OpenShift version.


## Provisioning this module in a Terraform Script

Use a `module` block assigning the `source` parameter to the location of this module. Then set the required [input variables](#inputs).

```hcl
module "cp4data" {
  source = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/cp4data_4.0/modules/cp4d4.0_ibm"
  enable = true

  // ROKS cluster parameters:
  cluster_config_path = data.ibm_container_cluster_config.cluster_config.config_file_path
  on_vpc              = var.on_vpc

  // Prereqs
  worker_node_flavor = var.worker_node_flavor
  operator_namespace = var.operator_namespace

  // Entitled Registry parameters:
  entitled_registry_key        = var.entitled_registry_key

  // CP4D License Acceptance
  accept_cpd_license = var.accept_cpd_license

  // CP4D Info
  cpd_project_name = "zen"

  // IBM Cloud API Key
  ibmcloud_api_key = var.ibmcloud_api_key

  region              = var.region
  resource_group_name = var.resource_group_name
  cluster_id          = var.cluster_id

  // Portworx, ODF, NFS
  storage_option      = var.storage_option

  // Parameters to install submodules
  install_wsl         = var.install_wsl
  install_aiopenscale = var.install_aiopenscale
  install_wml         = var.install_wml
  install_wkc         = var.install_wkc
  install_dv          = var.install_dv
  install_spss        = var.install_spss
  install_cde         = var.install_cde
  install_spark       = var.install_spark
  install_dods        = var.install_dods
  install_ca          = var.install_ca
  install_ds          = var.install_ds
  install_db2oltp     = var.install_db2oltp
  install_db2wh       = var.install_db2wh
  install_big_sql     = var.install_big_sql
  install_wsruntime   = var.install_wsruntime
}
```

For an example of how to provision and execute this module, go [here](../../example).

## Inputs
- `operator_namespace`: Namespace to install the operator in
- `ibmcloud_api_key`: IBM Cloud account API Key
- `cluster_id`: ID of the cluster to install on 
- `region`: Region that the cluster is provisioned in
- `resource_group_name`: Resource group that the cluster is provisioned in
- `on_vpc`: If set to `true`, it will set the install for a VPC cluster. By default it's set to `false`
- `worker_node_flavor`: Flavor of the cluster worker nodes.  Needed for storage determination.
- `entitled_registry_key`: Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary and assign it to this variable. Optionally you can store the key in a file and use the `file()` function to get the file content/key
- `accept_cpd_license`: If set to `true`, you accept all cpd license agreements including additional modules installed. By default, it's `false`
- `cpd_project_name`: Namespace to install CP4D in
- `storage_option`: Define the storage option. Defaults to `portworx`. (odf, nfs, portworx)
- `install_wsl`:  Install Watson Studio module. By default it's not installed. 
- `install_aiopenscale`: Install  Watson AI OpenScale module. By default it's not installed. 
- `install_wml`: Install Watson Machine Learning module. By default it's not installed.
- `install_wkc`: Install Watson Knowledge Catalog module. By default it's not installed.
- `install_dv`: Install Data Virtualization module. By default it's not installed.
- `install_spss`: Install SPSS Modeler module. By default it's not installed. 
- `install_cde`: Install Cognos Dashboard Engine module. By default it's not installed.  
- `install_spark`: Install Analytics Engine powered by Apache Spark module. By default it's not installed.
- `install_dods`: Install Decision Optimization module. By default it's not installed. 
- `install_ca`: Install Cognos Analytics module. By default it's not installed. 
- `install_ds`: Install DataStage module. By default it's not installed.
- `install_db2oltp`: Install Db2oltp module. By default it's not installed.
- `install_db2wh`: Install Db2 Warehouse module. By default it's not installed.         
- `install_big_sql`: Install Db2 Big SQL module. By default it's not installed.
- `install_wsruntime`: Install Jupyter Python 3.7 Runtime Addon. By default it's not installed.
- `cluster_config_path`: Directory to place kube config. For Schematic, it's recommended to use `/tmp/.schematics/.kube/config`

