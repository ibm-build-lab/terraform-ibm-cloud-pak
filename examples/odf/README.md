# Test ODF Terraform Module

## 1. Set up access to IBM Cloud

If running this module from your local terminal, you need to set the credentials to access IBM Cloud.

You can define the IBM Cloud credentials in the IBM provider block but it is recommended to pass them in as environment variables.

Go [here](../../CREDENTIALS.md) for details.

**NOTE**: These credentials are not required if running this Terraform code within an **IBM Cloud Schematics** workspace. They are automatically set from your account.

## 2. Test

### Using Terraform client

Follow these instructions to test the Terraform Module manually

Create the file `test.auto.tfvars` with the following input variables, these values are fake examples:

```hcl
enable                  = true
ibmcloud_api_key        = "<api-key>"

// Cluster parameters
kube_config_path        = ".kube/config"
worker_nodes            = 2  // Number of workers

// ODF parameters
resource_group_name     = "default"
region                  = "us-east"
cluster_id              = "<cluster-id>"
```

These parameters are:

- `ibmcloud_api_key`: IBM Cloud Key needed to provision resources.
- `config_dir`: Directory to download the kubeconfig file. Default value is `./.kube/config`
- `worker_nodes`: Number of worker nodes in the cluster
- `resource_group_name`: Resource group where the cluster is running. Default value is `Default`
- `region`: Region that the resources are in
- `cluster_id`: Cluster ID of the OpenShift cluster where to install IAF

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

## 3. Verify

To verify installation on the Openshift cluster you need `oc`, then execute:

After the service shows as active in the IBM Cloud resource view, verify the deployment:

    ibmcloud oc cluster addon ls -c <cluster_name>

This should display something like the following:

    openshift-data-foundation                 4.7.0     Normal     Addon Ready
    
Verify that the ibm-ocs-operator-controller-manager-***** pod is running in the kube-system namespace.

    oc get pods -A | grep ibm-ocs-operator-controller-manager

This should produce output like:

    kube-system              ibm-ocs-operator-controller-manager-58fcf45bd6-68pq5              1/1     Running            0          5d22h

## 4. Cleanup

WIP
