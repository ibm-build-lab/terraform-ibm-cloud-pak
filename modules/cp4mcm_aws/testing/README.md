# Test CP4MCM_aws Terraform Module

## 1. Set Cloud Pak Entitlement Key

This module also requires an Entitlement Key. Obtain it [here](https://myibm.ibm.com/products-services/containerlibrary) and store it in the file `entitlement.key` in the root of this repository. If you use that filename, the file won't be published to GitHub if you accidentally push to GitHub. 

## 2. Test Using Terraform client

Follow these instructions to test the Terraform Module manually using local Terraform client

Create the file `test.auto.tfvars` with the following input variables, these values are fake examples:

```hcl
entitled_registry_user_email = "John.Smith@ibm.com"
entitlement_key              = "********************************"
```

These parameters are:

- `entitled_registry_user_email`: username or email address of the user owner of the entitlement key. There is no default value, so this variable is required.
- `entitlement_key`: entitlement key secret for the user.

Execute the following Terraform commands:

```bash
terraform init
terraform plan

terraform apply -auto-approve
```

One of the Test Scenarios is to verify the YAML files rendered to install MCM, these files are generated in the directory `rendered_files`. Go to this directory to validate they are generated correctly.

## 3. Verify

To verify installation on the Kubernetes cluster you need `kubectl`, then execute:

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
```
To test MCM console use the address from the `endpoint` output parameter with the `user` and `password` output parameters as credentials.

```bash
terraform output user
terraform output password

open "https://$(terraform output endpoint)"
```

or

```bash
# URL to MCM Console
kubectl -n ibm-common-services get route cp-console  -o jsonpath='{.spec.host}'

# MCM Credentials
# User:
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_username}' | base64 -d
# Password:
kubectl -n ibm-common-services get secret platform-auth-idp-credentials -o jsonpath='{.data.admin_password}' | base64 -d
```

## 4. Cleanup

When the test is complete, execute: `terraform destroy` or `make clean`.

There are some directories and files you may want to manually delete, these are: `rm -rf test.auto.tfvars terraform.tfstate* .terraform .kube rendered_files`
