# Example to provision Multicloud Management System Terraform Module

## Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](../Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

## Run using local Terraform Client

For instructions to run using the Terraform Client on your local machine go [here](../Using_Terraform.md)

To run locally, you will need to create a `terraform.tfvars` file to customize the CP4MCM variables.  These are example values:

```hcl
cluster_id = "********************"
on_vpc = false
ibmcloud_api_key = "***********************"
entitled_registry_user_email = "2129514_john.doe@ibm.com"
entitled_registry_key = "************************************"
resource_group = "cloud-pak-sandbox"
install_infr_mgt_module = false
install_monitoring_module = false
install_security_svcs_module = false
install_operations_module = false
install_tech_prev_module = false
```

These parameters are:

- `cluster_id`: Cluster to install Cloud Pak on
- `on_vpc`: Type of cluster infrastructure
- `ibmcloud_api_key`: the entitlement key from https://myibm.ibm.com/products-services/containerlibrary
- `entitled_registry_user_email`: username or email address of the user owner of the entitlement key. There is no default value, so this variable is required.
- `entitled_registry_key`: the entitlement key from https://myibm.ibm.com/products-services/containerlibrary
- `resource_group`: Resource group where the cluster is running. Default value is `default`
- `cluster_id`: Cluster ID of the OpenShift cluster where to install CP4MCM
- `install_infr_mgt_module`: Install the Infrastructure Management module
- `install_monitoring_module`: Install the Monitoring module
- `install_security_svcs_module`: Install the Security Services module
- `install_operations_module`: Install the Operations module
- `install_tech_prev_module`: Install the Tech Preview module
- `cluster_config_path`: Directory to place kube config. For Schematic, it's recommended to use `/tmp/.schematics/.kube/config`

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## Output Variables

Once the Terraform execution completes, use the following output variables to access CP4MCM Dashboard:

| Name        | Description                                                     |
| ----------- | --------------------------------------------------------------- |
| `console_url`  | URL of the dashboard                                     |
| `user`      | Username to log in to the dashboard                       |
| `password`  | Password to log in to the dashboard                       |

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

To test MCM console use the address from the `console_url` output parameter with the `user` and `password` output parameters as credentials.

```bash
terraform output user
terraform output password

open "https://$(terraform output console_url)"
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

When the test is complete, execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf terraform.tfstate* .terraform .kube`
