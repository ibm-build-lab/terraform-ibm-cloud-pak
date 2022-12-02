#!/bin/sh

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

cat << EOF | kubectl apply -f -
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
    accept: ${ACCEPT_LICENSE}
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

###
# Wait for AIOpsAnalyticsOrchestrator to create..
evtCount=0
evtTimeout=15 #15 mins
SLEEP_TIME="60"
while true; do
  if [ "$evtCount" -eq "$evtTimeout" ]; then
    echo "Kind: AIOpsAnalyticsOrchestrator did not create a resource. Please check the Installation: ibm-aiops"
    exit 1
  fi
  # Check to make sure it exists:
  # Wait for AIOpsAnalyticsOrchestrator resource creation and then check for the instance creation.
  if [ "`kubectl api-resources | grep AIOpsAnalyticsOrchestrator`" != "" ]; then
    if [ "`kubectl get AIOpsAnalyticsOrchestrator aiops -n ${NAMESPACE} --ignore-not-found=true`" != "" ]; then
      break
    fi
  fi
  echo "Waiting for AIOpsAnalyticsOrchestrator resource, sleeping ${SLEEP_TIME} seconds"
  sleep $SLEEP_TIME
  evtCount=$(( evtCount+1 ))
done

echo "=== Adding pull secret to the ibm-aiops-orchestrator operator"

# Edit file and add the pull secret
cat <<EOF | kubectl apply -f -
apiVersion: ai.ir.aiops.ibm.com/v1beta1
kind: AIOpsAnalyticsOrchestrator
metadata:
  name: aiops
  namespace: $NAMESPACE
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
  topologyInstanceName: aiops
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
  echo "waiting 1 minute"
  sleep 60
fi


# CHECK STATUS OF INSTALLATION
is_complete_ircore=false
is_complete_AIOpsAnalyticsOrchestrator=false
is_complete_lifecycleservice=false
is_complete_BaseUI=false
is_complete_AIManager=false
is_complete_aiopsedge=false
is_complete_asm=false

SLEEP_TIME="60" # seconds
TIMEOUT_LIMIT=240 # 240min = 4hr timeout
TIMEOUT_COUNT=0

while true; do
    if [ "$TIMEOUT_COUNT" -eq "$TIMEOUT_LIMIT" ]; then
        echo "=== problem installing custom resource, please check the operator log/events ==="
        kubectl get installations.orchestrator.aiops.ibm.com -A &&
            echo "" && kubectl get ircore,AIOpsAnalyticsOrchestrator -A -o custom-columns="KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,STATUS:status.conditions[?(@.type==\"Ready\")].reason" &&
            echo "" && kubectl get lifecycleservice -A -o custom-columns="KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,STATUS:status.conditions[?(@.type==\"Lifecycle Service Ready\")].reason" &&
            echo "" && kubectl get BaseUI -A -o custom-columns="KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,STATUS:status.conditions[?(@.type==\"Ready\")].reason" &&
            echo "" && kubectl get AIManager,aiopsedge,asm -A -o custom-columns="KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,STATUS:status.phase"
        exit 1
    fi

    if $is_complete_ircore && $is_complete_AIOpsAnalyticsOrchestrator && $is_complete_lifecycleservice && $is_complete_BaseUI && $is_complete_AIManager && $is_complete_aiopsedge && $is_complete_asm; then
        break
    fi

    if [ $is_complete_ircore = false ] && [ "`kubectl get ircore -A --output='jsonpath={.items[*].status.conditions[?(@.type=="Ready")].reason}'`" == "Ready"  ]; then
        echo "ircore is ready"
        is_complete_ircore=true
    fi

    if [ $is_complete_AIOpsAnalyticsOrchestrator = false ] && [ "`kubectl get AIOpsAnalyticsOrchestrator -A --output='jsonpath={.items[].status.conditions[?(@.type=="Ready")].reason}'`" == "Ready" ]; then
        echo "AIOpsAnalyticsOrchestrator is ready"
        is_complete_AIOpsAnalyticsOrchestrator=true
    fi

    if [ $is_complete_lifecycleservice = false ] && [ "`kubectl get lifecycleservice -A --output='jsonpath={.items[].status.conditions[?(@.type=="Lifecycle Service Ready")].reason}'`" == "Ready" ]; then
        echo "lifecycleservice is ready"
        is_complete_lifecycleservice=true
    fi

    if [ $is_complete_BaseUI = false ] && [ "`kubectl get BaseUI -A --output='jsonpath={.items[].status.conditions[?(@.type=="Ready")].reason}'`" == "Ready" ]; then
        echo "BaseUI is ready"
        is_complete_BaseUI=true
    fi

    if [ $is_complete_AIManager = false ] && [ "`kubectl get AIManager -A --output='jsonpath={.items[].status.phase}'`" == "Completed" ]; then
        echo "AIManager is ready"
        is_complete_AIManager=true
    fi

    if [ $is_complete_aiopsedge = false ] && [ "`kubectl get aiopsedge -A --output='jsonpath={.items[].status.phase}'`" == "Configured" ]; then
        echo "aiopsedge is ready"
        is_complete_aiopsedge=true
    fi

    if [ $is_complete_asm = false ] && [ "`kubectl get asm -A --output='jsonpath={.items[].status.phase}'`" == "OK" ]; then
        echo "asm is ready"
        is_complete_asm=true
    fi

    # Every 10minutes, display status of installation
    if (($TIMEOUT_COUNT % 10 == 0)); then
        kubectl get installations.orchestrator.aiops.ibm.com -A &&
            echo "" && kubectl get ircore,AIOpsAnalyticsOrchestrator -A -o custom-columns="KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,STATUS:status.conditions[?(@.type==\"Ready\")].reason" &&
            echo "" && kubectl get lifecycleservice -A -o custom-columns="KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,STATUS:status.conditions[?(@.type==\"Lifecycle Service Ready\")].reason" &&
            echo "" && kubectl get BaseUI -A -o custom-columns="KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,STATUS:status.conditions[?(@.type==\"Ready\")].reason" &&
            echo "" && kubectl get AIManager,aiopsedge,asm -A -o custom-columns="KIND:kind,NAMESPACE:metadata.namespace,NAME:metadata.name,STATUS:status.phase"
    fi 

    echo "Sleeping $SLEEP_TIME seconds"
    sleep $SLEEP_TIME
    TIMEOUT_COUNT=$(( TIMEOUT_COUNT+1 ))
done

echo '=== Installation Complete ==='