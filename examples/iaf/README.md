# Example to provision IAF Terraform Module

## Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](../Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md)
setting these values in the `terraform.tfvars` file:

```bash
on_vpc                       = "false"
cluster_id                   = "*******************"
ibmcloud_api_key             = "********************************"
resource_group               = "cloud-pak-sandbox"
region                       = "us-south"
entitled_registry_user_email = "john.doe@ibm.com"
entitled_registry_key        = "****************************"
```

These parameters are:

- `on_vpc`: Infrastructure where the cluster is running. The possible values are: `true` and `false`. The default value is `false`.
- `cluster_id`: Cluster ID of the OpenShift cluster where to install IAF
- `ibmcloud_api_key`: IBMCloud API key (See https://cloud.ibm.com/docs/account?topic=account-userapikey#create_user_key)
- `region`: Region where the cluster is running.
- `resource_group`: Resource group where the cluster is running.
- `entitled_registry_user_email`: username or email address of the user owner of the entitlement key. There is no default value, so this variable is required.
- `entitled_registry_key`: Entitlement key for above user. Get the entitlement key from https://myibm.ibm.com/products-services/containerlibrary

### Verify

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
### Cleanup

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
