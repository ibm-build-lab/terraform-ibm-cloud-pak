#!/bin/sh
echo "Applying the Db2 LocalVolume to the cluster."

# TODO: Dynamically update path_to_disk from TF.
path_to_disk="/dev/vdb"

cat << EOF | kubectl apply -f -
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