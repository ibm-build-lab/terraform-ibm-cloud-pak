# Example to provision Portworx Terraform Module (this module only supports VPC clusters)

## Run using IBM Cloud Schematics

For instructions to run these examples using IBM Schematics go [here](../Using_Schematics.md)

For more information on IBM Schematics, refer [here](https://cloud.ibm.com/docs/schematics?topic=schematics-get-started-terraform).

## Run using local Terraform Client

For instructions to run using the local Terraform Client on your local machine go [here](../Using_Terraform.md)
setting these values in the `terraform.tfvars` file:

```hcl
ibmcloud_api_key        = "<api-key>"

// Cluster parameters
worker_nodes            = 4  // Number of workers

// Storage parameters
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
```

These parameters are:

- `ibmcloud_api_key`: IBM Cloud Key needed to provision resources.
- `worker_nodes`: Number of worker nodes on the cluster
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

## 3. Verify

To verify installation on the Kubernetes cluster you need `kubectl`, then execute:

After the service shows as active in the IBM Cloud resource view, verify the deployment:

```bash
kubectl get pods -n kube-system | grep 'portworx\|stork'
```

This should display something like the following:

```console
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
```

Using one of the portworx pods, check the status of the storage cluster

```bash
kubectl exec portworx-647c5 -it -n kube-system -- /opt/pwx/bin/pxctl status
```

This should produce output like:

```console
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
```

To review classificiation:

```bash
kubectl exec -it <portworx_pod> -n kube-system -- /opt/pwx/bin/pxctl cluster provision-status
```

## 4. Cleanup

Run in the cluster:

```bash
curl -fsL https://install.portworx.com/px-wipe | bash
```

When the test is complete, execute: `terraform destroy`.

There are some directories and files you may want to manually delete, these are: `rm -rf terraform.tfstate* .terraform .kube
