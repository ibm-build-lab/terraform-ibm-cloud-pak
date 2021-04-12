# Test CP4MCM Terraform Module

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

## 3. Set Cloud Pak Entitlement Key

This module also requires an Entitlement Key. Obtain it [here](https://myibm.ibm.com/products-services/containerlibrary) and store it in the file `entitlement.key` in the root of this repository. If you use that filename, the file won't be published to GitHub if you accidentally push to GitHub. 

## 4. Test

### Using "make"

The module needs the username or email address of the owner of the entitlement key. Set this variable:

```bash
export TF_VAR_entitled_registry_user_email="John.Smith@ibm.com"
```

Test using `make`, like so:

```bash
make
make test-kubernetes
make test-mcm
```

### Using Terraform client

Follow these instructions to test the Terraform Module manually

Create the file `test.auto.tfvars` with the following input variables, these values are fake examples:

```hcl
infra                        = "classic"
config_dir                   = ".kube/config"
cluster_id                   = "btvlh6bd0di5v70fhqn0"
entitled_registry_user_email = "John.Smith@ibm.com"
resource_group               = "cp4mcm-test"
```

These parameters are:

- `entitled_registry_user_email`: username or email address of the user owner of the entitlement key. There is no default value, so this variable is required.
- `infra`: Infrastructure where the cluster is running. The possible values are: `classic` and `vpc`. The default value and only supported at this time is `classic`.
- `resource_group`: Resource group where the cluster is running. Default value is `default`
- `config_dir`: Directory to download the kubeconfig file. Default value is `./.kube/config`
- `cluster_id`: Cluster ID of the OpenShift cluster where to install CP4MCM

Execute the following Terraform commands:

```bash
terraform init
terraform plan

terraform apply -auto-approve
```

One of the Test Scenarios is to verify the YAML files rendered to install MCM, these files are generated in the directory `rendered_files`. Go to this directory to validate they are generated correctly.

## 5. Verify

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

## 6. Cleanup

When the test is complete, execute: `terraform destroy` or `make clean`.

There are some directories and files you may want to manually delete, these are: `rm -rf test.auto.tfvars terraform.tfstate* .terraform .kube rendered_files`
