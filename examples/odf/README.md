# Test Portworx Terraform Module

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

// Storage parameters
install_storage         = true
storage_capacity        = 200  // In GBs
storage_iops            = 10   // Must be a number, it will not be used unless a storage_profile is set to a custom profile
storage_profile         = "10iops-tier"

// Portworx parameters
resource_group_name     = "default"
region                  = "us-east"
cluster_id              = "<cluster-id>"
unique_id               = "roks-px-tf"

// These credentials have been hard-coded because the 'Databases for etcd' service instance is not configured to have a publicly accessible endpoint by default.
// You may override these for additional security.
create_external_etcd    = false
etcd_username           = "portworxuser"
etcd_password           = "portworxpassword"
etcd_secret_name        = "px-etcd-certs" # don't change this
```

These parameters are:

- `ibmcloud_api_key`: IBM Cloud Key needed to provision resources.
- `config_dir`: Directory to download the kubeconfig file. Default value is `./.kube/config`
- `worker_nodes`: Number of worker nodes in the cluster
- `install_storage`: Do you want to install storage or do you have your own? Default value is `true`
- `storage_capacity`: Number in GBs for a block storage. Default value is `200`
- `storage_iops`: Number of iops for a drive. Default to `10` however it will not be used unless `storage_profile` is a custom profile
- `resource_group_name`: Resource group where the cluster is running. Default value is `Default`
- `region`: Region that the resources are in
- `cluster_id`: Cluster ID of the OpenShift cluster where to install IAF
- `unique_id`: Unique name for the Portworx Service
- `create_external_etcd`: Do you want to create an external etcd? Default value is `false`
- `etcd_username`: Username of etcd. Only used if `create_external_etcd` is set to `true`
- `etcd_password`: Password of etcd. Only used if `create_external_etcd` is set to `true`

Execute the following Terraform commands:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

One of the Test Scenarios is to verify the YAML files rendered to install IAF, these files are generated in the directory `rendered_files`. Go to this directory to validate that they are generated correctly.

## 3. Verify

To verify installation on the Kubernetes cluster you need `kubectl`, then execute:

After the service shows as active in the IBM Cloud resource view, verify the deployment:

    kubectl get pods -n kube-system | grep 'portworx\|stork'

This should display something like the following:

    portworx-647c5                            1/1     Running     0          9m33s
    portworx-api-h7dnr                        1/1     Running     0          9m33s
    portworx-api-ndpxb                        1/1     Running     0          9m33s
    portworx-api-srnjk                        1/1     Running     0          9m33s
    portworx-gzgqc                            1/1     Running     0          9m33s
    portworx-pvc-controller-b8c88b4d7-6rnq6   1/1     Running     0          9m33s
    portworx-pvc-controller-b8c88b4d7-9bfxk   1/1     Running     0          9m33s
    portworx-pvc-controller-b8c88b4d7-nqqpr   1/1     Running     0          9m33s
    portworx-vxphk                            1/1     Running     0          9m33s
    stork-6f74dcf5fc-mxwxb                    1/1     Running     0          9m33s
    stork-6f74dcf5fc-svnrl                    1/1     Running     0          9m33s
    stork-6f74dcf5fc-z9qlc                    1/1     Running     0          9m33s
    stork-scheduler-7d755b5475-grzr2          1/1     Running     0          9m33s
    stork-scheduler-7d755b5475-nl25m          1/1     Running     0          9m33s
    stork-scheduler-7d755b5475-trhhb          1/1     Running     0          9m33s

Using one of the portworx pods, check the status of the storage cluster

    kubectl exec portworx-647c5 -it -n kube-system -- /opt/pwx/bin/pxctl status

This should produce output like:

    Status: PX is operational
    License: PX-Enterprise IBM Cloud (expires in 1201 days)
    Node ID: 5d65ce5b-1333-4b0c-b469-ccf7df1ce94a
      IP: 172.26.0.10 
      Local Storage Pool: 1 pool
      POOL    IO_PRIORITY  RAID_LEVEL  USABLE    USED     STATUS  ZONE      REGION
      0       LOW          raid0       400 GiB   18 GiB   Online  us-east-1 us-east
      Local Storage Devices: 1 device
      Device  Path      Media Type               Size     Last-Scan
      0:1     /dev/vdd  STORAGE_MEDIUM_MAGNETIC  400 GiB  18 Dec 20 04:43 UTC
      * Internal kvdb on this node is sharing this storage device /dev/vdd  to store its data.
      total   -         400 GiB
      Cache Devices:
        * No cache devices
    Cluster Summary
      Cluster ID: pwx-iaf
      Cluster UUID: 45fc03a8-7e82-497d-bc2a-0844dca1459f
      Scheduler: kubernetes
      Nodes: 3 node(s) with storage (3 online)
      IP           ID                                   SchedulerNodeName  StorageNode  Used    Capacity  Status  StorageStatus Version         Kernel                      OS
      172.26.0.9   f96e278c-fd06-42a8-9684-0d91bc0bde9c 172.26.0.9         Yes          18 GiB  400 GiB   Online  Up            2.6.1.6-3409af2 3.10.0-1160.6.1.el7.x86_64  Red Hat
      172.26.0.10  5d65ce5b-1333-4b0c-b469-ccf7df1ce94a 172.26.0.10        Yes          18 GiB  400 GiB   Online  Up (This node 2.6.1.6-3409af2 3.10.0-1160.6.1.el7.x86_64  Red Hat
      172.26.0.11  1b56ec6c-6dcd-4807-a9cd-cf1ae12e7635 172.26.0.11        Yes          18 GiB  400 GiB   Online  Up            2.6.1.6-3409af2 3.10.0-1160.6.1.el7.x86_64  Red Hat
      Warnings: 
          WARNING: Internal Kvdb is not using dedicated drive on nodes [172.26.0.11 172.26.0.9 172.26.0.10]. This configuration is not recommended for production clusters.
    Global Storage Pool
      Total Used      :  53 GiB
      Total Capacity  :  1.2 TiB

To review classificiation:

    kubectl exec -it <portworx_pod> -n kube-system -- /opt/pwx/bin/pxctl cluster provision-status

## 4. Cleanup

Run in the cluster:

    curl -fsL https://install.portworx.com/px-wipe | bash

When the test is complete, execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf test.auto.tfvars terraform.tfstate* .terraform .kube rendered_files`
