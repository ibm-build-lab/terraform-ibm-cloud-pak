# Test CP4App Terraform Module

## 1. Set up access to IBM Cloud

If running this module from your local terminal, you need to set the credentials to access IBM Cloud.

You can define the IBM Cloud credentials in the IBM provider block but it is recommended to pass them in as environment variables.

Go [here](../../CREDENTIALS.md) for details.

**NOTE**: These credentials are not required if running this Terraform code within an **IBM Cloud Schematics** workspace. They are automatically set from your account.

## 2. Set OpenShift cluster environment variables

This module test requires a running OpenShift cluster on IBM Cloud Classic with the basic MCM requirements. You need the cluster ID or name, and the resource group where it is running. These 2 parameters are passed to the testing code as environment variables. Execute this code:

```bash
export TF_VAR_cluster_id=<cluster_id>
export TF_VAR_resource_group=<resource_group>
```

## 3. Set Cloud Pak entitlement key

The second requirement is to have an Entitlement Key, to obtain it [here](https://myibm.ibm.com/products-services/containerlibrary) and store it in the file `entitlement.key` in the root of this repository. If you use that filename, the file won't be published to GitHub if you accidentally push to GitHub. 

The module also needs the username or email address of the owner of the entitlement key. Set this variable:

```bash
export TF_VAR_entitled_registry_user_email="John.Smith@ibm.com"
```

## 4. Test

### Using "make"

For a quick test use `make`, like so:

```bash
make
make test-kubernetes
make test-app
```

### Using Terraform

Create the file `test.auto.tfvars` with the following input variables, these values are fake examples:

```hcl
infra                        = "classic"
config_dir                   = ".kube/config"
cluster_id                   = "btvlh6bd0di5v70fhqn0"
entitled_registry_user_email = "John.Smith@ibm.com"
resource_group               = "cp4app-test"
```

These parameters are:

- `entitled_registry_user_email`: username or email address of the user owner of the entitlement key. There is no default value, so this variable is required.
- `infra`: Infrastructure where the cluster is running. The possible values are: `classic` and `vpc`. The default value and only supported at this time is `classic`.
- `resource_group`: Resource group where the cluster is running. Default value is `default`
- `config_dir`: Directory to download the kubeconfig file. Default value is `./.kube/config`
- `cluster_id`: Cluster ID of the OpenShift cluster where to install CP4App

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## 5. Verify

To verify installation on the Kubernetes cluster you need `kubectl`, then execute:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output namespace)
```

To test the Applications dashboards open in a browser the address from the different endpoint output parameters.

```bash
open $(terraform output endpoint)

open $(terraform output advisor_ui_endpoint)

open $(terraform output navigator_ui_endpoint)
```

### Cleanup

When the test is complete, execute: `terraform destroy` or `make clean`.

There are some directories and files you may want to delete manually, these are: `rm -rf test.auto.tfvars terraform.tfstate* .terraform .kube`
