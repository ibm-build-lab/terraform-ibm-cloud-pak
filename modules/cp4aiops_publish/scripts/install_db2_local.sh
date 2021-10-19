#!/bin/sh

K8s_CMD=kubectl
# TODO: Update OCP_VERSION dynamically for local-storage-operator
# OCP_VERSION="'4.6'"

cat << EOF | ${K8s_CMD} apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: local-storage
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: local-operator-group
  namespace: local-storage
spec:
  targetNamespaces:
    - local-storage
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: local-storage-operator
  namespace: local-storage
spec:
  channel: '4.7'
  installPlanApproval: Automatic
  name: local-storage-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF


echo "Waiting 2 minutes for local-storage operator to install"
sleep 120

echo "Applying the Db2 LocalVolume to the cluster."

# TODO: Dynamically update path_to_disk from TF.
path_to_disk="/dev/vdb"

cat << EOF | ${K8s_CMD} apply -f -
apiVersion: "local.storage.openshift.io/v1"
kind: "LocalVolume"
metadata:
  name: "local-disks-db2"
  namespace: "local-storage"
spec:
  storageClassDevices:
    - storageClassName: "db2storageclass"
      volumeMode: Filesystem
      fsType: ext4
      devicePaths:
      - ${path_to_disk}
EOF

