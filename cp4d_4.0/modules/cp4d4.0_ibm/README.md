# Terraform Module to install Cloud Pak for Data

This Terraform Module installs **Cloud Pak for Data** on an Openshift (ROKS) cluster on IBM Cloud.

**Module Source**: `github.com/ibm-build-lab/terraform-ibm-cloud-pak.git//cp4data_4.0/modules/cp4d4.0_ibm`

## Set up access to IBM Cloud

If running these modules from your local terminal, you need to set the credentials to access IBM Cloud.

Go [here](../../CREDENTIALS.md) for details.

## Provisioning this module in a Terraform Script

See details in [this](../../../README.md) directory on how to use this module

### Setting up the OpenShift cluster

NOTE: an OpenShift cluster is required to install the Cloud Pak. This can be an existing cluster or can be provisioned using our `roks` Terraform module.

To provision a new cluster, refer [here](https://github.com/ibm-build-lab/terraform-ibm-cloud-pak/tree/main/roks#building-a-new-roks-cluster) for the code to add to your Terraform script. The recommended size for an OpenShift 4.10+ cluster on IBM Cloud Classic contains `4` workers of flavor `b3c.16x64`, however read the [Cloud Pak for Data documentation](https://www.ibm.com/docs/en/cloud-paks/cp-data) to confirm these parameters or if you are using IBM Cloud VPC or a different OpenShift version.

## Executing the Terraform Script

Execute the following commands to install the Cloud Pak:

```bash
terraform init
terraform plan
terraform apply
```

## Accessing the Cloud Pak Console

After execution has completed, access the cluster using `kubectl` or `oc`:

```bash
oc get route -n ${NAMESPACE} cpd -o jsonpath='{.spec.host}' && echo
```

To get default login id:

```bash
username = "admin"
```

To get default Password:

```bash
oc -n ${NAMESPACE} get secret admin-user-details -o jsonpath='{.data.initial_admin_password}' | base64 -d && echo
```

## Clean up

When you finish using the cluster, release the resources by executing the following command:

```bash
terraform destroy
```

## Troubleshooting

- Once `module.cp4data.null_resource.bedrock_zen_operator` completes. You can check the logs to find out more information about the installation of Cloud Pak for Data.

```bash
cpd-meta-operator: oc -n cpd-meta-ops logs -f deploy/ibm-cp-data-operator

cpd-install-operator: oc -n cpd-tenant logs -f deploy/cpd-install-operator
```
