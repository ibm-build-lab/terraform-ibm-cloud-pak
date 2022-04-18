#!/bin/sh

echo "creating namespace ${NAMESPACE}"
kubectl create namespace ${NAMESPACE}

echo "=== finished creating namespace: ${NAMESPACE} ==="