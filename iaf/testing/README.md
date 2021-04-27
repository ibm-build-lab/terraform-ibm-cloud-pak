# Test IAF Terraform Module

## 1. Set up access to IBM Cloud

If running this module from your local terminal, you need to set the credentials to access IBM Cloud.

You can define the IBM Cloud credentials in the IBM provider block but it is recommended to pass them in as environment variables.

Go [here](../../CREDENTIALS.md) for details.

**NOTE**: These credentials are not required if running this Terraform code within an **IBM Cloud Schematics** workspace. They are automatically set from your account.

## 2. Set Cloud Pak Entitlement Key

This module also requires an Entitlement Key. Obtain it [here](https://myibm.ibm.com/products-services/containerlibrary) and store it in the file `entitlement.key` in the root of this repository. If you use that filename, the file won't be published to GitHub if you accidentally push to GitHub.

## 3. Test

### Using Terraform client

Follow these instructions to test the Terraform Module manually

Create the file `test.auto.tfvars` with the following input variables, these values are fake examples:

```hcl
on_vpc                       = "false"
config_dir                   = ".kube/config"
cluster_id                   = "btvlh6bd0di5v70fhqn0"
entitled_registry_user_email = "John.Smith@ibm.com"
resource_group               = "iaf-test"
```

These parameters are:

- `entitled_registry_user_email`: username or email address of the user owner of the entitlement key. There is no default value, so this variable is required.
- `on_vpc`: Infrastructure where the cluster is running. The possible values are: `true` and `false`. The default value is `false`.
- `resource_group`: Resource group where the cluster is running. Default value is `Default`
- `config_dir`: Directory to download the kubeconfig file. Default value is `./.kube/config`
- `cluster_id`: Cluster ID of the OpenShift cluster where to install IAF

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

One of the Test Scenarios is to verify the YAML files rendered to install IAF, these files are generated in the directory `rendered_files`. Go to this directory to validate that they are generated correctly.

## 5. Verify

To verify installation on the Kubernetes cluster you need `kubectl`, then execute:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output namespace)

# CatalogSource
kubectl -n openshift-marketplace get catalogsource | grep IBM

# Subscription
kubectl -n $(terraform output namespace) get subscription | grep ibm-automation

## 6. Cleanup

When the test is complete, execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf test.auto.tfvars terraform.tfstate* .terraform .kube rendered_files`
