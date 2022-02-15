#!/bin/sh

echo "Creating ibm-entitlement-key secret"
kubectl create secret docker-registry ibm-entitlement-key \
    --docker-username=cp\
    --docker-password=${ENTITLEMENT_KEY} \
    --docker-server=cp.icr.io \
    --namespace=${NAMESPACE}

echo "Creating Service Account for AIOPS"
cat <<EOF | kubectl apply -n ${NAMESPACE} -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: aiops-topology-service-account
  labels:
    managedByUser: 'true'
imagePullSecrets:
  - name: ibm-entitlement-key
EOF

echo "Finished creating secret and service account."