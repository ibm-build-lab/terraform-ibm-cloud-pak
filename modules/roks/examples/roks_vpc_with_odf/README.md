# IBM Red Hat OpenShift VPC Managed Cluster with ODF Parameters and Installation

## Set up

If running using your local Terraform Client, copy `terraform.tfvars.vpc` to `terraform.tfvars` and ensure your values are set properly.  
 
## Input Parameters

The Terraform script requires the following list of input variables. Here are some instructions to set their values for Terraform and how to get their values from IBM Cloud. Pay attention to the parameters required for **Classic** vs **VPC**.

| Name | Description  | Default | Required |
| - | - | - | - |
| `entitlement`          | Enter `cloud_pak` if using a Cloud Pak entitlement. Leave blank if using OCP entitlement |              | No       |
| `region`               | Ignored if `cluster_id` is specified. IBM Cloud region to host the cluster. List all available zones with: `ibmcloud is regions` | `us-south`           | No       |
| `resource_group`       | Resource Group used to host the cluster. List all available resource groups with: `ibmcloud resource groups`   | `Default`        | No       |
| `roks_version`         | OpenShift version to install. List all available versions: `ibmcloud ks versions`. There is no need to include the suffix `_OpenShift`. The module will append it to install the specified version of OpenShift.  | `4.10`            | No       |
| `project_name`         | Used to name new cluster along with the `environment` name, like this: `{project_name}-{environment}-cluster`<br />It's also used to label the cluster and other resources  |  | Yes      |
| `owner`                | Optional: User name or team name. Used to label the cluster and other resources   |  | Yes      |
| `environment`          | Ignored if `cluster_id` is specified. Used to name the cluster with the `project` name, like this: `{project_name}-{environment}-cluster` | `dev`            | No       |
| `vpc_zone_names`       | Array with the sub-zones in the region to create the workers groups. List all the zones with: `ibmcloud ks zone ls --provider vpc-gen2`. Example: `["us-south-1", "us-south-2", "us-south-3"]`   | `["ca-tor-1"]` | No       |
| `flavors`              | Array with the flavors or machine types of each of the workers.  List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2` or `ibmcloud ks flavors --zone dal10 --provider classic`. On Classic it is only possible to have one worker group, so only list one flavor, i.e. `["b3c.16x64"]`. Example on VPC `["mx2.4x32", "mx2.8x64", "cx2.4x8"]` or `["mx2.4x32"]`  | `["mx2.4x32"]`   | No       |
| `workers_count`        | Array with the amount of workers on each workers group. On Classic it's only possible to have one workers group, so only the first number in the list is taken for the cluster size. Example: `[1, 3, 5]` or `[2]`   | `[2]`            | Yes       |
| `force_delete_storage` | If set to `true`, force the removal of persistent storage associated with the cluster during cluster deletion. Default value is `false`.                                                             | `false`          | Yes       |
| `ibmcloud_api_key`   | IBMCloud API Key for the account the resources will be provisioned on. Go to https://cloud.ibm.com/iam/apikeys to create a key  |           | Yes       |
| `osdStorageClassName`  | Storage class that you want to use for your OSD devices | `ibmc-vpc-block-metro-10iops-tier` | Yes       |
| `osdSize`   | Size of your storage devices. The total storage capacity of your ODF cluster is equivalent to the osdSize x 3 divided by the numOfOsd | `250Gi` | Yes       |
| `osdDevicePaths`                   | IDs of the disks to be used for OSD pods if using local disks or standard classic cluster |  | No   |
| `numOfOsd`      | Number object storage daemons (OSDs) that you want to create. ODF creates three times the numOfOsd value | `1` | Yes       |
| `billingType`                   | Billing Type for your ODF deployment (`essentials` or `advanced`) | `advanced` | Yes       |
| `ocsUpgrade`                   | Whether to upgrade the major version of your ODF deployment | `false` | Yes       |
| `clusterEncryption`                   | Enable encryption of storage cluster | `false` | Yes       |
| `monSize`                   | Size of the storage devices that you want to provision for the monitor pods. The devices must be at least 20Gi each | `20Gi` | Yes (Only roks 4.7)       |
| `monStorageClassName`                   | Storage class to use for your Monitor pods. For VPC clusters you must specify a block storage class | `ibmc-vpc-block-metro-10iops-tier` | Yes (Only roks 4.7)       |
| `monDevicePaths`                   | Please provide IDs of the disks to be used for mon pods if using local disks or standard classic cluster | | No (Only for roks 4.7)       |
| `autoDiscoverDevices`                   | Auto Discover Devices | `false` | No (Not available for roks version 4.7)       |
| `hpcsEncryption`                   | Use Hyper Protect Crypto Services | `false` | No (Only available for roks version 4.10)       |
| `hpcsServiceName`                   | Enter the name of your Hyper Protect Crypto Services instance. For example: `Hyper-Protect-Crypto-Services-eugb`" |  | No (Only available for roks version 4.10)    |
| `hpcsInstanceId`                   | Enter your Hyper Protect Crypto Services instance ID. For example: `d11a1a43-aa0a-40a3-aaa9-5aaa63147aaa` |  | No (Only available for roks version 4.10)    |
| `hpcsSecretName`                   | Enter the name of the secret that you created by using your Hyper Protect Crypto Services credentials. For example: `ibm-hpcs-secret` |  | No (Only available for roks version 4.10)    |
| `hpcsBaseUrl`                   | Enter the public endpoint of your Hyper Protect Crypto Services instance. For example: `https://api.eu-gb.hs-crypto.cloud.ibm.com:8389` |  | No (Only available for roks version 4.10)    |
| `workerNodes` | **Optional**: array of node names for the worker nodes that you want to use for your ODF deployment. This parameter is by default not specified, so ODF will use all the worker nodes in the cluster. To add this to the module, uncomment it from the `../variables.tf` file, add it to the `spec` section in `../templates/install_odf.yaml.tmpl` and in the `templatefile` call in `../main.tf`. To add it to this example, uncomment it from the `variables.tf` file, and add it to the call to the module in `./main.tf`. | | No

## Output Parameters

The module returns the following output variables:

| Name       | Description                                             |
| ---------- | ------------------------------------------------------- |
| `endpoint` | The URL of the public service endpoint for your cluster |
| `id`       | The unique identifier of the cluster.                   |
| `name`     | The name of the cluster                                 |

## Validation

If you use the cluster from other terraform code there may be no need to download the kubeconfig file. However, if you plan to use the cluster from the CLI (i.e. `kubectl`) or other application then it's recommended to download it to some directory.

After execution has completed, access the cluster using `kubectl` or `oc`:

```bash
ibmcloud ks cluster config -cluster $(terraform output cluster_id)
kubectl cluster-info
```

<b>For ODF:</b>

If you have not setup `kubectl` to access the cluster, execute:

```bash
# If created with Terraform:
ibmcloud ks cluster config --cluster $(terraform output cluster_id)

# If created with Schematics:
ibmcloud ks cluster config --cluster $(ibmcloud schematics workspace output --id $WORKSPACE_ID --json | jq -r '.[].output_values[].cluster_id.value')

# If created with IBM Cloud CLI:
ibmcloud ks cluster config --cluster $CLUSTER_NAME
```

Verify the cluster is up and running executing these commands:

```bash
kubectl cluster-info
kubectl get nodes
kubectl get pods --all-namespaces
```

Execute the following commands to validate this Cloud Pak:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info
```

To verify that ODF is installed, run the command:
```bash
ibmcloud oc cluster addon ls -c $(terraform output cluster_id)
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
