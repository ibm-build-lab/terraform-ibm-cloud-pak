# Terraform Module to install Openshift Data Foundation on a VPC cluster

This Terraform Module installs the **ODF Service** on an Openshift (ROKS) cluster on IBM Cloud.

**NOTE:** An Openshift cluster is required with at least three worker nodes. Each worker node must have a minimum of 16 CPUs and 64 GB RAM. https://cloud.ibm.com/docs/openshift?topic=openshift-deploy-odf-vpc for more information.

**Module Source**: `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//modules/odf`

### Provisioning the ODF Module

For an example of how to provision and execute this module, go [here](./example).

## Input Variables

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

## Output Variable

| Name                           | Description                                                                                                                                                                                                                | 
| ------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `odf_is_ready`                       | Flag set when ODF has completed its install.  Used when adding this with other modules |

For an example of how to put all this together, refer to our [OpenShift Data Foundation Terraform Example](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/examples/odf).


## Executing the Terraform Script

Run the following commands to execute the TF script (containing the modules to create/use ROKS and ODF). Execution may take about 5-15 minutes:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Clean up

When the cluster is no longer needed, run `terraform destroy` if this was created using your local Terraform client with `terraform apply`. 

If this cluster was created using `schematics`, just delete the schematics workspace and specify to delete all created resources.

<b>For ODF:</b>

To uninstall ODF and its dependencies from a cluster, execute the following commands:

While logged into the cluster

```bash
terraform destroy -target null_resource.enable_odf
```
This will disable the ODF on the cluster

Once this completes, execute: `terraform destroy` if this was create locally using Terraform or remove the Schematic's workspace.



