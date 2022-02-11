#!/bin/sh

K8s_CMD=kubectl
db2_namespace="local-storage"
# TODO: Update OCP_VERSION dynamically for local-storage-operator
# OCP_VERSION="'4.6'"
echo
echo "Running the Db2 local volume installation file ..."
echo

OC_VERSION=$(oc version -o yaml | grep openshiftVersion | grep -o '[0-9]*[.][0-9]*' | head -1)
echo

cat << EOF | ${K8s_CMD} apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${db2_namespace}
---
apiVersion: operators.coreos.com/v1alpha2
kind: OperatorGroup
metadata:
  name: local-operator-group
  namespace: openshift-local-storage
spec:
  targetNamespaces:
    - ${db2_namespace}
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: local-storage-operator
  namespace: local-storage
spec:
  channel: "${OC_VERSION}"
  installPlanApproval: Automatic
  name: local-storage-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF

echo
echo "Waiting 2 minutes for local-storage operator to install"
sleep 60

echo
echo "Checking that all pods and the Local Storage Operator have been successfully created ..."
${K8s_CMD} get pods -n ${db2_namespace}

echo
echo "Create the Db2 local volume resource in your OpenShift Container Platform cluster ..."
echo
# TODO: Dynamically update path_to_disk from TF.
path_to_disk="/dev/vdb"

cat << EOF | ${K8s_CMD} apply -f -
apiVersion: local.storage.openshift.io/v1
kind: LocalVolume
metadata:
  name: local-disks-db2
  namespace: ${db2_namespace}
spec:
  storageClassDevices:
    - storageClassName: db2storageclass
      volumeMode: Filesystem
      fsType: ext4
      devicePaths:
      - ${path_to_disk}
EOF

sleep 30
echo
echo "Getting all the provisioner that was just created ..."
${K8s_CMD} get all -n ${db2_namespace}
echo

