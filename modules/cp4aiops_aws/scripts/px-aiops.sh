#!/bin/sh

echo "creating storage classes"

# This storage class is used for event management and other components.
cat << EOF | oc apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portworx-fs
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "3"
  io_profile: "db"
  priority_io: "high"
allowVolumeExpansion: true
EOF

# This storage class is used for AI management.
cat << EOF | oc apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: portworx-aiops
provisioner: kubernetes.io/portworx-volume
parameters:
  repl: "3"
  priority_io: "high"
  snap_interval: "0"
  io_profile: "db"
  block_size: "64k"
  sharedv4: "true"
allowVolumeExpansion: true
EOF