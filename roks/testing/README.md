# Test ROKS Terraform Module

For a quick test, **Export the credentials for IBM Cloud Classic or VPC** (step #1 below) then use `make` to execute the test on IBM Cloud Classic, like so:

```bash
make
make test-kubernetes
make clean
```

To test on IBM Cloud VPC, execute instead:

```bash
make test-vpc
make test-kubernetes
make clean
```

Follow these instructions to manually test the Terraform module

## 1. Export the credentials for IBM Cloud Classic or VPC

Execute the following code replacing the values in angular brackets (`< >`) by the respective credentials/keys:

```bash
export IAAS_CLASSIC_USERNAME="< IBM Cloud Username/Email >"
export IAAS_CLASSIC_API_KEY="< IBM Cloud Classic API Key >"
export IC_API_KEY="< IBM Cloud API Key >"
```

Optionally create the file `credentials.sh` with the code above and execute it with `source credentials.sh`. If you choose other filename for the credentials, make sure to include it in the `.gitignore` file or do NOT commit the file to Github.

## 2. Test

Execute the following Terraform commands:

```bash
terraform init
terraform plan
```

Apply the Terraform code using the flag `-var="infra=___"` to set the value of the variable `infra` using either `classic` or `vpc` as values. Like so:

```bash
terraform apply -var="infra=classic" -auto-approve
```

Other variable worth to set is `owner`, if not set the value `tester` is used. For `owner` is recommended to set your username. If you are on Linux or macOS, use this command:

```bash
export TF_VAR_owner=$USER
```

You can set the other variables using the `-var` flag method, exporting the environment variables `TF_VAR_<name>` or using the `terraform.tfvars` file. The other variables available to set are:

- `config_dir`: directory to store the kubeconfig file, set the value to empty string to not download the config. Default value is `./kube/config`.
- `project_name`: the project name is used as a tag/label and to name the cluster, like: `{project_name}-{environment}-cluster`. Default value is `roks`
- `environment`: the environment is used as a tag/label and to name the cluster, like: `{project_name}-{environment}-cluster`. Default value is `test`
- `resource_group`: resource group where to create the cluster. Default value is `default`
- `roks_version`: Kubernetes version to install, for Openshift clusters the version suffix is `_openshift`. List the available versions executing `ibmcloud ks versions` or check the version in [IBM Cloud Kubernetes Service](https://cloud.ibm.com/docs/containers?topic=containers-cs_versions) or [Red Hat OpenShift on IBM Cloud](https://cloud.ibm.com/docs/openshift?topic=openshift-openshift_versions#version_types). Default value is `4.4_openshift`.
- `flavors`: List with the flavors or machine types of each the workers group. List all flavors for each zone with: `ibmcloud ks flavors --zone us-south-1 --provider vpc-gen2`. Example: `[mx2.4x32, mx2.8x64, cx2.4x8]`. Default value is `[mx2.4x32]`
- `workers_count`: List with the amount of workers on each workers group. Example: `[1, 3, 5]`. Default value is `[2]`
- `datacenter`: Input variables only for IBM Cloud Classic. List all available datacenters/zones with: `ibmcloud ks zone ls --provider classic`. Default value is `dal10`
- `vpc_zone_names`: Input variables only for IBM Cloud VPC. List with the subzones in the region, to create the workers groups. List all the zones with: `ibmcloud ks zone ls --provider vpc-gen2`. Example: `[us-south-1, us-south-2, us-south-3]`. Default value is `[us-south-1]`

## 3. Test the Kubernetes cluster

To test the Kubernetes cluster you need `kubectl`, then execute:

```bash
export KUBECONFIG=$(terraform output config_file_path)

kubectl cluster-info
kubectl get namespace terraform-module-is-working
```

## 4. Destroy

When tests is successfully complete, execute: `terraform destroy`
