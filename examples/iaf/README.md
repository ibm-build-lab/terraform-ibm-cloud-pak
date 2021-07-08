# IAF Terraform Module example

## Run using IBM Cloud Schematics

To run from a schematics workspace, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-about-schematics#how-to-workspaces).

## Run using local Terraform Client

To run using the local Terraform Client on your local machine follow these steps:

### Prerequisites

If running this example from your local terminal, you will need to:

- Have an IBM Cloud account with required privileges
- [Install IBM Cloud CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-ibm-cloud-cli)
- [Install the IBM Cloud CLI Plugins](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#ibm-cloud-cli-plugins) `schematics` and `kubernetes-service`.
- [Login to IBM Cloud with the CLI](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#login-to-ibm-cloud)
- [Install Terraform](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#install-terraform) **version 0.12**
- [Install IBM Cloud Terraform Provider](https://ibm.github.io/cloud-enterprise-examples/iac/setup-environment#configure-access-to-ibm-cloud)
- Install utility tools:
  - [jq](https://stedolan.github.io/jq/download/)
  - [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
  - [oc](https://docs.openshift.com/container-platform/3.6/cli_reference/get_started_cli.html)


### Set up access to IBM Cloud

You can define the IBM Cloud credentials in the IBM provider block but it is recommended to pass them in as environment variables.

Go [here](../../CREDENTIALS.md) for details.

**NOTE**: These credentials are not required if running this Terraform code within an **IBM Cloud Schematics** workspace. They are automatically set from your account.

### Set Cloud Pak Entitlement Key

This module also requires an Entitlement Key. Obtain it [here](https://myibm.ibm.com/products-services/containerlibrary) and store it in the file `entitlement.key` in the root of this cloned repository (../..). If you use that filename, the file won't be published to GitHub if you accidentally push to GitHub.

### Execute

Create the file `terraform.tfvars` with the following input variables. NOTE: these values are just examples:

```hcl
on_vpc                       = "false"
config_dir                   = ".kube/config"
cluster_id                   = "btvlh6bd0di5v70fhqn0"
entitled_registry_user_email = "John.Smith@ibm.com"
resource_group               = "Default"
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

### Verify

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
```

### Cleanup

To remove IAF from cluster, execute: `terraform destroy`.

In addition, execute the following commands on the cluster:

```bash
kubectl delete -n openshift-marketplace catalogsource.operators.coreos.com opencloud-operators
kubectl delete -n iaf subscription.operators.coreos.com ibm-automation
kubectl delete -n openshift-operators operatorgroup.operators.coreos.com iaf-group
kubectl delete namespace iaf
```

There are some directories and files you may want to manually delete, these are: `rm -rf terraform.tfstate* .terraform .kube`
