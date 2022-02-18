#!/bin/sh

# -----REMOVE---------
# ON_VPC=false
# -----REMOVE---------

K8s_CMD=kubectl

NAMESPACE=${NAMESPACE:-aiops}
DOCKER_USERNAME=${DOCKER_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed

# TODO:
# Potentially pull this out and put it into the TF script instead.
if ${ON_VPC}; then
  storage_class="portworx-fs"
  storage_block_class="portworx-aiops"
else
  storage_class="ibmc-file-gold-gid"
  storage_block_class="ibmc-file-gold-gid"
fi

# TODO:
# Create license var for T/F
cat << EOF | oc apply -f -
apiVersion: orchestrator.aiops.ibm.com/v1alpha1
kind: Installation
metadata:
  name: ibm-aiops
  namespace: ${NAMESPACE}
spec:
  size: small
  storageClass: ${storage_class}
  storageClassLargeBlock: ${storage_block_class}
  imagePullSecret: ibm-entitlement-key
  license:
    accept: true
  pakModules:
  - name: aiopsFoundation
    enabled: true
  - name: applicationManager
    enabled: true
  - name: aiManager
    enabled: true
    config:
    - name: aimanager-operator
      spec:
        aimanager:
          integratorProxy:
            enabled: false
            proxyRoute: ""
  - name: connection
    enabled: false
EOF


echo "=== Adding pull secret to the ibm-aiops-orchestrator operator"

# Edit file and add the pull secret
cat <<EOF | kubectl apply -f -
apiVersion: ai.ir.aiops.ibm.com/v1beta1
kind: AIOpsAnalyticsOrchestrator
metadata:
  name: aiops
  namespace: aiops
spec:
  cassandra:
    bindingSecret: aiops-topology-cassandra-auth-secret
    host: aiops-topology-cassandra
    portNumber: 9042
    secretName: aiops-topology-cassandra-auth-secret
  couch:
    bindingSecret: ibm-aiops-couchdb-secret
    host: example-couchdbcluster
    portNumber: 443
    secretName: c-example-couchdbcluster-m
  datalayer:
    stdApiAuthSecretName: aiops-ir-core-ncodl-std-secret
    stdApiCaSecretName: aiops-ir-core-service-ca
    stdApiHost: aiops-ir-core-ncodl-std
    stdApiPort: 10011
  deployedFeatures:
    probableCause: true
    sparkRuntime: true
  kafka:
    bindingSecret: ibm-aiops-kafka-secret
  license:
    accept: true
  size: small
  topologyInstanceName: aiops,
  pullSecrets:
  - ibm-aiops-pull-secret
EOF

# Find the pod and restart it if it is there.
echo '=== checking for aiops-ir-analytics pod ==='
POD_NAME=`kubectl get csv -n $NAMESPACE | grep aiops-ir-analytics | awk '{print $1}'`
if [ "$POD_NAME" == "" ]; then
  echo "aiops-ir-analytics was not found, skipping..."
else 
  echo "restarting $POD_NAME..."
  kubectl delete pod $POD_NAME -n $NAMESPACE
fi


# to find installation on cluster
#oc get installations.orchestrator.aiops.ibm.com -n aiops

echo '=== Installation Complete ==='