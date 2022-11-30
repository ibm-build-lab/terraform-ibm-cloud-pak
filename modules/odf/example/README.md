# OpenShift Data Foundation Terraform Module Example

**NOTE:** an OpenShift VPC cluster is required to install this module. This can be an existing cluster or can be provisioned using our [roks](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/modules/roks) Terraform module.

## Execution

### Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/blob/main/Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

### Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/blob/main/Using_Terraform.md). 

Create a file `terraform.tfvars` with the following input variables (these are examples):

```hcl
ibmcloud_api_key        = "<api-key>"
cluster                 = "<cluster-id>"
roks_version            = "<cluster version, i.e. 4.7, 4.8, 4.9, 4.10>"

// ODF Parameters
// OpenShift version 4.7 only options
monSize = "20Gi"
monStorageClassName = "ibmc-vpc-block-10iops-tier"
monDevicePaths = ""
// OpenShift version 4.8+ only options
autoDiscoverDevices = var.autoDiscoverDevices
// OpenShift version 4.7+ options
osdStorageClassName = "ibmc-vpc-block-10iops-tier"
osdSize = "250Gi"
osdDevicePaths = ""
numOfOsd = 1
billingType = "advanced"
ocsUpgrade = false
clusterEncryption = false
// OpenShift version 4.10+ options
hpcsEncryption = false
hpcsServiceName = ""
hpcsInstanceId = ""
hpcsBaseUrl = ""
hpcsTokenUrl = ""
hpcsSecretName = ""
```

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

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
| `workerNodes` | **Optional**: array of node names for the worker nodes that you want to use for your ODF deployment. This parameter is by default not specified, so ODF will use all the worker nodes in the cluster. To add this to the module, uncomment it from the `../variables.tf` file, add it to the `spec` section in `../templates/install_odf.yaml.tmpl` and in the `templatefile` call in `../main.tf`. To add it to this example, uncomment it from the `variables.tf` file, and add it to the call to the module in `./main.tf`. | | No

## Verify

To verify installation on the Openshift cluster you need `oc`, then execute:

After the service shows as active in the IBM Cloud resource view, verify the deployment:

    ibmcloud oc cluster addon ls -c <cluster_name>

This should display something like the following:

    openshift-data-foundation                 4.10.0     Normal     Addon Ready
    
Verify that the ibm-ocs-operator-controller-manager-***** pod is running in the kube-system namespace.

    oc get pods -A | grep ibm-ocs-operator-controller-manager

This should produce output like:

    kube-system              ibm-ocs-operator-controller-manager-58fcf45bd6-68pq5              1/1     Running            0          5d22h

## Cleanup

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

