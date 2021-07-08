# Example to provision IAF Terraform Module

## Run using IBM Cloud Schematics
For instructions to run these examples using IBM Schematics go here

For more information on IBM Schematics, refer here.

## Run using local Terraform Client

### 1. Set up access to IBM Cloud

If running this module from your local terminal, you need to set the credentials to access IBM Cloud.

You can define the IBM Cloud credentials in the IBM provider block but it is recommended to pass them in as environment variables.

Go [here](../CREDENTIALS.md) for details.

**NOTE**: These credentials are not required if running this Terraform code within an **IBM Cloud Schematics** workspace. They are automatically set from your account.

### 2. Set Cloud Pak Entitlement Key

This module also requires an Entitlement Key. Obtain it [here](https://myibm.ibm.com/products-services/containerlibrary) and either store it in the file `entitlement.key` in the root of this repository. If you use that filename, the file won't be published to GitHub if you accidentally push to GitHub.

### 3. Configure variables

Create the file `terraform.tfvars` with the following input variables. NOTE: these values are just examples:

```bash
on_vpc                       = "false"
cluster_id                   = "*******************"
ibmcloud_api_key             = "********************************"
resource_group               = "cloud-pak-sandbox"
region                       = "us-south"
entitled_registry_user_email = "john.doe@ibm.com"
entitled_registry_key        = "****************************"
config_dir                   = ".kube/config"
```

These parameters are:

- `on_vpc`: Infrastructure where the cluster is running. The possible values are: `true` and `false`. The default value is `false`.
- `cluster_id`: Cluster ID of the OpenShift cluster where to install IAF
- `ibmcloud_api_key`: IBMCloud API key (See https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)
- `region`: Region where the cluster is running.
- `resource_group`: Resource group where the cluster is running.
- `entitled_registry_user_email`: username or email address of the user owner of the entitlement key. There is no default value, so this variable is required.
- `entitled_registry_key`: Entitlement key for above user. Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary
- `config_dir`: Directory to download the kubeconfig file. Default value is `./.kube/config`

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

One of the Test Scenarios is to verify the YAML files rendered to install IAF, these files are generated in the directory `rendered_files`. Go to this directory to validate that they are generated correctly.

## 5. Verify

To verify IAF installation, execute:

```bash
ibmcloud ks cluster config -c <cluster_id> --admin

# Namespace
kubectl get namespaces iaf

# CatalogSource
kubectl -n openshift-marketplace get catalogsource | grep IBM

# Subscription
kubectl -n iaf get subscription | grep ibm-automation
```
## 6. Cleanup

When the test is complete, execute: `terraform destroy`.

In addition. execute the following commands:

```bash
kubectl delete -n openshift-marketplace catalogsource.operators.coreos.com opencloud-operators
kubectl delete -n iaf subscription.operators.coreos.com ibm-automation
kubectl delete -n openshift-operators operatorgroup.operators.coreos.com iaf-group
kubectl delete namespace iaf
```

to uninstall IAF and its dependencies from the cluster.

There are some directories and files you may want to manually delete, these are: `rm -rf test.auto.tfvars terraform.tfstate* .terraform .kube rendered_files`
