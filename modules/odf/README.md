# Terraform Module to install Openshift Data Foundation on a VPC cluster

This Terraform Module installs the **ODF Service** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/odf`

**NOTE:** an OpenShift cluster with at least three worker nodes is required to install this module. This can be an existing cluster or can be provisioned using our [roks](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/roks) Terraform module.

Each worker node must have a minimum of 16 CPUs and 64 GB RAM. https://cloud.ibm.com/docs/openshift?topic=openshift-deploy-odf-vpc for more information.


### Provisioning the ODF Module
Use a `module` block assigning the `source` parameter to the location of this module. Then set the required [input variables](#inputs).
```
module "odf" {
  source = "github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/odf"
  cluster = var.cluster
  ibmcloud_api_key = var.ibmcloud_api_key
  roks_version = var.roks_version

  // ODF parameters
  monSize = var.monSize
  monStorageClassName = var.monStorageClassName
  monDevicePaths = var.monDevicePaths
  autoDiscoverDevices = var.autoDiscoverDevices
  osdStorageClassName = var.osdStorageClassName
  osdSize = var.osdSize
  osdDevicePaths = var.osdDevicePaths
  numOfOsd = var.numOfOsd
  billingType = var.billingType
  ocsUpgrade = var.ocsUpgrade
  clusterEncryption = var.clusterEncryption
  #workerNodes = var.workerNodes
  hpcsEncryption = var.hpcsEncryption
  hpcsServiceName = var.hpcsServiceName
  hpcsInstanceId = var.hpcsInstanceId
  hpcsBaseUrl = var.hpcsBaseUrl
  hpcsTokenUrl = var.hpcsTokenUrl
  hpcsSecretName = var.hpcsSecretName
}
```

For an example of how to provision and execute this module, go [here](./example).

## Inputs

| Name                           | Description                                                                                                                                                                                                                | Default | Required |
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------- | -------- |
| `ibmcloud_api_key`             | This requires an ibmcloud api key found here: `https://cloud.ibm.com/iam/apikeys`    |         | Yes       |
| `cluster`                   | The id of the OpenShift cluster to be installed on |  | Yes       |
| `roks_version`                   | ROKS Cluster version (4.7 or higher) |  | Yes       |
| `osdStorageClassName`                   | Storage class that you want to use for your OSD devices | ibmc-vpc-block-metro-10iops-tier | Yes       |
| `osdSize`                   | Size of your storage devices. The total storage capacity of your ODF cluster is equivalent to the osdSize x 3 divided by the numOfOsd | 250Gi | Yes       |
| `osdDevicePaths`                   | Please provide IDs of the disks to be used for OSD pods if using local disks or standard classic cluster |  | No   |
| `numOfOsd`                   | Number object storage daemons (OSDs) that you want to create. ODF creates three times the numOfOsd value | 1 | Yes       |
| `billingType`                   | Billing Type for your ODF deployment (`essentials` or `advanced`) | advanced | Yes       |
| `ocsUpgrade`                   | Whether to upgrade the major version of your ODF deployment | false | Yes       |
| `clusterEncryption`                   | Enable encryption of storage cluster | false | Yes       |
| `monSize`                   | Size of the storage devices that you want to provision for the monitor pods. The devices must be at least 20Gi each | 20Gi | Yes (Only roks 4.7)       |
| `monStorageClassName`                   | Storage class to use for your Monitor pods. For VPC clusters you must specify a block storage class | ibmc-vpc-block-metro-10iops-tier | Yes (Only roks 4.7)       |
| `monDevicePaths`                   | Please provide IDs of the disks to be used for mon pods if using local disks or standard classic cluster | | No (Only for roks 4.7)       |
| `autoDiscoverDevices`                   | Auto Discover Devices | false | No (Not available for roks version 4.7)       |
| `hpcsEncryption`                   | Use Hyper Protect Crypto Services | false | No (Only available for roks version 4.10)       |
| `hpcsServiceName`                   | Enter the name of your Hyper Protect Crypto Services instance. For example: Hyper-Protect-Crypto-Services-eugb" |  | No (Only available for roks version 4.10)    |
| `hpcsInstanceId`                   | Enter your Hyper Protect Crypto Services instance ID. For example: d11a1a43-aa0a-40a3-aaa9-5aaa63147aaa |  | No (Only available for roks version 4.10)    |
| `hpcsSecretName`                   | Enter the name of the secret that you created by using your Hyper Protect Crypto Services credentials. For example: ibm-hpcs-secret |  | No (Only available for roks version 4.10)    |
| `hpcsBaseUrl`                   | Enter the public endpoint of your Hyper Protect Crypto Services instance. For example: https://api.eu-gb.hs-crypto.cloud.ibm.com:8389 |  | No (Only available for roks version 4.10)    |
| `workerNodes` | **Optional**: array of node names for the worker nodes that you want to use for your ODF deployment. This parameter is by default not specified, so ODF will use all the worker nodes in the cluster. To add this to the module, uncomment it from the `variables.tf` file, add it to the `spec` section in `templates/install_odf.yaml.tmpl` and in the `templatefile` call in `main.tf` | | No

## Outputs

| Name                           | Description                                                                                                                                                                                                                | 
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `odf_is_ready`                       | Flag set when ODF has completed its install.  Used when adding this with other modules |


