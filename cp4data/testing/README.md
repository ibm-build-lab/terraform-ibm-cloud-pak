# Test CP4DATA Terraform Module

This module test requires to have a running OpenShift cluster with - at least - the basic DATA requirements. You need the cluster ID or name, and the resource group where it is running. These 2 parameters are passed to the module on environment variables, see below.

The second requirement is to have an Entitlement Key, to obtain such key go to https://myibm.ibm.com/products-services/containerlibrary and store it in the file `entitlement.key` in the root of this repository. If you use that filename, the file won't be published to GitHub. The module also needs the username or email address of the user owner of the entitlement key. Export the username and the cluster parameters in the following environment variables, for example:

```bash
export TF_VAR_cluster_id=btvlh6bd0di5v70fhqn0
export TF_VAR_resource_group=cloud-pak-testing

export TF_VAR_entitled_registry_user_email="John.Smith@ibm.com"
```

The third and final requirement is to **Export the credentials for IBM Cloud** (step #1 below) in environment variables.

For a quick test use `make` to execute the test on IBM Cloud Classic, like so:

```bash
make
make test-kubernetes
make test-data
```

To test DATA open in a browser the address from the `endpoint` output parameter using the `user` and `password` output parameters as credentials.

```bash
terraform output user
terraform output password

open "https://$(terraform output endpoint)"
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

Create the file `test.auto.tfvars` with the following input variables, the values are fake examples:

```hcl
infra                        = "classic"
config_dir                   = ".kube/config"
cluster_id                   = "btvlh6bd0di5v70fhqn0"
entitled_registry_user_email = "John.Smith@ibm.com"
```

Execute the following Terraform commands:

```bash
terraform init
terraform plan

terraform apply -auto-approve
```

The most common variables you can set in the `test.auto.tfvars` file are:

- `entitled_registry_user_email`: username or email address of the user owner of the entitlement key. There is no default value, so this variable is required.
- `infra`: Infrastructure where the cluster is running. The possible values are: `classic` and `vpc`. The default value is `classic`.
- `resource_group`: Resource group where the cluster is running. Default value is `default`
- `config_dir`: Directory to download the kubeconfig file. Default value is `./.kube/config`

One of the Test Scenario is to verify the YAML files rendered to install DATA, these files are generated in the directory `rendered_files`. Go to this directory to validate they are generated correctly.

## 3. Test the Kubernetes cluster

To test the Kubernetes cluster you need `kubectl`, then execute:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info

# Namespace
kubectl get namespaces $(terraform output namespace)

# Secret
kubectl get secrets -n $(terraform output namespace) ibm-management-pull-secret -o yaml

# CatalogSource
kubectl -n openshift-marketplace get catalogsource
kubectl -n openshift-marketplace get catalogsource ibm-management-orchestrator
kubectl -n openshift-marketplace get catalogsource opencloud-operators

# Subscription
kubectl -n openshift-operators get subscription ibm-common-service-operator-stable-v1-opencloud-operators-openshift-marketplace ibm-management-orchestrator operand-deployment-lifecycle-manager-app

# Ingress
kubectl -n openshift-ingress get route router-default

# Installation
kubectl -n $(terraform output namespace) get installations.orchestrator.management.ibm.com ibm-management

# URL to DATA Console
kubectl -n ibm-common-services get route cp-console  -o jsonpath='{.spec.host}'

# DATA Credentials
# User:
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 -d
# Password:
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d
```

## 4. Destroy

When execution is successfully complete, execute: `terraform destroy`.

There are some directories and file you may want to delete, these are: `rm -rf test.auto.tfvars terraform.tfstate* .terraform .kube rendered_files`
