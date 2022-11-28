# OpenShift Data Foundation Terraform Module Example

## 1. Set up access to IBM Cloud

If running this module from your local terminal, you need to set the credentials to access IBM Cloud.

You can define the IBM Cloud credentials in the IBM provider block but it is recommended to pass them in as environment variables.

Go [here](../../CREDENTIALS.md) for details.

You also need to install the [IBM Cloud cli](https://cloud.ibm.com/docs/cli?topic=cli-install-ibmcloud-cli) as well as the [OpenShift cli](https://cloud.ibm.com/docs/openshift?topic=openshift-openshift-cli)

Make sure you have the latest updates for all IBM Cloud plugins by running `ibmcloud plugin update`.  

**NOTE**: These requirements are not required if running this Terraform code within an **IBM Cloud Schematics** workspace. They are automatically set from your account.

## 2. Test

### Using Terraform client

Follow these instructions to test the Terraform Module manually

Create a file `terraform.tfvars` with the following input variables:

```hcl
ibmcloud_api_key        = "<api-key>"
cluster                 = "<cluster-id>"
roks_version            = "<cluster version>"

// ODF Parameters
monSize = "20Gi"
monStorageClassName = "ibmc-vpc-block-10iops-tier"
osdStorageClassName = "ibmc-vpc-block-10iops-tier"
osdSize = "200Gi"
numOfOsd = 1
billingType = "advanced"
ocsUpgrade = false
clusterEncryption = false
```

These parameters are:

- `ibmcloud_api_key`: IBM Cloud Key needed to provision resources.
- `cluster`: Cluster ID of the OpenShift cluster where to install IAF
- `roks_version`: ROKS Cluster version (4.7 or higher)
- `osdStorageClassName`: Storage class that you want to use for your OSD devices
- `osdSize`: Size of your storage devices. The total storage capacity of your ODF cluster is equivalent to the osdSize x 3 divided by the numOfOsd
- `numOfOsd`: Number object storage daemons (OSDs) that you want to create. ODF creates three times the numOfOsd value
- `billingType`: Billing Type for your ODF deployment ('essentials' or 'advanced')
- `ocsUpgrade`: Whether to upgrade the major version of your ODF deployment
- `clusterEncryption`: Enable encryption of storage cluster
- `monSize`:Size of the storage devices that you want to provision for the monitor pods. The devices must be at least 20Gi each (Only roks 4.7)
- `monStorageClassName`: Storage class to use for your Monitor pods. For VPC clusters you must specify a block storage class (Only roks 4.7)

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## 3. Verify

To verify installation on the Openshift cluster you need `oc`, then execute:

After the service shows as active in the IBM Cloud resource view, verify the deployment:

    ibmcloud oc cluster addon ls -c <cluster_name>

This should display something like the following:

    openshift-data-foundation                 4.7.0     Normal     Addon Ready
    
Verify that the ibm-ocs-operator-controller-manager-***** pod is running in the kube-system namespace.

    oc get pods -A | grep ibm-ocs-operator-controller-manager

This should produce output like:

    kube-system              ibm-ocs-operator-controller-manager-58fcf45bd6-68pq5              1/1     Running            0          5d22h

## 4. Cleanup

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

