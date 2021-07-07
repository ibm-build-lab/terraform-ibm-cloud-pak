# Provisioning an OpenShift cluster using IBM Cloud CLI

The creation of the cluster using the IBM Cloud CLI may not be the best option but you can use it if there is a problem with Terraform or Schematics. Or, if you'd like to use and reuse this cluster for multiple test scenarios.

The OpenShift cluster is created using the `ibmcloud` command and the `kubernetes-service` plugin. The existing Cloud Paks are tested and supported on IBM Cloud Classic.

## Provisioning on **IBM Cloud Classic**

```bash
export IAAS_CLASSIC_USERNAME="< Your IBM Cloud Username/Email here >"
export IAAS_CLASSIC_API_KEY="< Your IBM Cloud Classic API Key here >"

export PROJECT_NAME="cp-sandbox"

ibmcloud ks versions | grep _OpenShift
export VERSION="4.4"

ibmcloud ks zone ls --provider classic
export ZONE="dal10"

ibmcloud ks flavors --zone $ZONE
export FLAVOR="b3c.4x16"

export CLUSTER_NAME="${PROJECT_NAME}-cluster"
export SIZE=1

ibmcloud ks cluster create classic \
          --name $CLUSTER_NAME \
          --version $VERSION \
          --zone $ZONE \
          --flavor $FLAVOR \
          --workers $SIZE \
          --entitlement cloud_pak

ibmcloud ks cluster config --cluster $CLUSTER_NAME

kubectl cluster-info
```

## Destroy the cluster

To destroy the cluster, execute the following commands:

```bash
ibmcloud ks cluster rm \
  --cluster $CLUSTER_NAME \
  --force-delete-storage

# If created on VPC
ibmcloud is subnet-delete $SUBNET_ID
ibmcloud is vpc-delete $VPC_ID
```
