# Test CP4App Terraform Module

This module test requires to have a running OpenShift cluster on IBM Cloud Classic with the basic requirements to run Cloud Pak for Applications. You need the cluster ID or name, and the resource group where it is running. These 2 parameters are passed to the testing code on environment variables, see below.

The second requirement is to have an Entitlement Key, to obtain it go to https://myibm.ibm.com/products-services/containerlibrary and store it in the file `entitlement.key` in the root of this repository. If you use that filename, the file won't be published to GitHub if you accidentally push to GitHub. The module also needs the username or email address of the user owner of the entitlement key.

Export the entitlement key and cluster parameters in the following environment variables:

```bash
export TF_VAR_cluster_id=btvlh6bd0di5v70fhqn0
export TF_VAR_resource_group=cloud-pak-testing

export TF_VAR_entitled_registry_user_email="John.Smith@ibm.com"
```

The third and final requirement is to **[Export the credentials for IBM Cloud](#1-export-the-credentials-for-ibm-cloud)** using environment variables.

For a quick test use `make`, like so:

```bash
make
make test-kubernetes
make test-mcm
```

To test the Applications dashboards open in a browser the address from the different endpoint output parameters.

```bash
open $(terraform output endpoint)

open $(terraform output advisor_ui_endpoint)

open $(terraform output navigator_ui_endpoint)
```

When the test is complete, you may destroy everything executing `make clean`

Follow these instructions to test the Terraform Module manually

## 1. Export the credentials for IBM Cloud

Execute the following code replacing the values in angular brackets (`< >`) by the respective credentials/keys:

```bash
export IAAS_CLASSIC_USERNAME="< IBM Cloud Username/Email >"
export IAAS_CLASSIC_API_KEY="< IBM Cloud Classic API Key >"
export IC_API_KEY="< IBM Cloud API Key >"
```

Optionally create the file `credentials.sh` with the code above and execute it with `source credentials.sh`. If you choose other filename for the credentials, make sure to include it in the `.gitignore` file or do NOT commit the file to Github.

## 2. Test

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

## 3. Test the Kubernetes cluster

To test the Kubernetes cluster you need `kubectl`, then execute:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output namespace)
```

## 4. Destroy

When execution is successfully complete, execute: `terraform destroy`.

There are some directories and file you may want to delete, these are: `rm -rf test.auto.tfvars terraform.tfstate* .terraform .kube`
