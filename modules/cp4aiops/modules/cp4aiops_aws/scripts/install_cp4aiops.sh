#!/bin/sh

NAMESPACE=${NAMESPACE:-aiops}
DOCKER_USERNAME=${DOCKER_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed

# Create custom namespace
echo "Creating namespace ${NAMESPACE}"
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

create_secret() {
  secret_name=$1
  namespace=$2
  link=$3

  echo "Creating secret ${secret_name} on ${namespace} from entitlement key"
  oc create secret docker-registry ${secret_name} \
    --docker-server=${DOCKER_REGISTRY} \
    --docker-username=${DOCKER_USERNAME} \
    --docker-password=${DOCKER_REGISTRY_PASS} \
    --docker-email=${DOCKER_USER_EMAIL} \
    --namespace=${namespace}
}

create_secret ibm-entitlement-key "${NAMESPACE}"


# Configure a network policy for the IBM Cloud Pak for Watson AIOps routes
echo "Configuring the network policy for CP4AIPS routes"
oc get ingresscontroller default -n openshift-ingress-operator -o yaml
oc patch namespace default --type=json -p '[{"op":"add","path":"/metadata/labels","value":{"network.openshift.io/policy-group":"ingress"}}]'


# Configure a network policy for traffic between the Operator Lifecycle Manager and the CatalogSource service
echo "Configuring network policy for traffic between Operator Lifecycle Manager and CatalogSource service."

cat << EOF | oc apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-all-egress-and-ingress
  namespace: ${NAMESPACE}
spec:
  egress:
  - {}
  ingress:
  - {}
  podSelector: {}
  policyTypes:
  - Egress
  - Ingress
EOF


echo "Adding IBM Cloud Pak for Watson AIOps Orchestrator CatalogSource"

cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ibm-aiops-catalog
  namespace: openshift-marketplace
spec:
  address: ibm-aiops-catalog.openshift-marketplace:50051
  displayName: IBM AIOps Catalog
  publisher: IBM
  sourceType: grpc
  image: icr.io/cpopen/aiops-orchestrator-catalog:3.1-latest
  updateStrategy:
    registryPoll:
      interval: 45m
EOF

echo "Adding IBM Operators CatalogSource"

cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: ibm-operator-catalog
  namespace: openshift-marketplace
spec:
  displayName: ibm-operator-catalog 
  publisher: IBM Content
  sourceType: grpc
  image: docker.io/ibmcom/ibm-operator-catalog:latest
  updateStrategy:
    registryPoll:
      interval: 45m
EOF

echo "Adding IBM Common Services CatalogSource"
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: opencloud-operators
  namespace: openshift-marketplace
spec:
  displayName: IBMCS Operators
  publisher: IBM
  sourceType: grpc
  image: docker.io/ibmcom/ibm-common-service-catalog:latest
  updateStrategy:
    registryPoll:
      interval: 45m
EOF

echo "Sleeping 1 minutes for catalog services"
sleep 60

echo "Applying CP4AIOPS subscription"
echo "${CP4AIOPS_SUB}" | oc apply -f -


echo "Waiting 5 minutes for AIOps Operator to install..."
sleep 300

# AIOPs CR called here
echo "Applying CP4AIOPS service"
echo "${CP4AIOPS_SERVICE}" | oc -n ${NAMESPACE} apply -f  -

SLEEP_TIME="60"
SERVICE_TIMEOUT_LIMIT=90
RUN_LIMIT=2
service_timeout_count=0
run_limit_count=0

while true; do
  if ! STATUS_LONG=$(oc -n ${NAMESPACE} get installation.orchestrator.aiops.ibm.com ibm-cp-watson-aiops --output=json | jq -c -r '.status'); then
    echo 'Error getting status'
    exit 1
  fi

  echo $STATUS_LONG
 
  STATUS=$(echo $STATUS_LONG | jq -c -r '.locations')
  if [ $STATUS != "{}" ]; then
    break
  fi
  
  echo "Sleeping $SLEEP_TIME seconds..."
  sleep $SLEEP_TIME
  

  (( service_timeout_count++ ))
  # Checks to see if the service took too long. If so, it restarts the service
  if [ "$service_timeout_count" -eq "$SERVICE_TIMEOUT_LIMIT" ]; then
    service_timeout_count=0
    (( run_limit_count++ ))

    echo "Waited ${SERVICE_TIMEOUT_LIMIT} minutes. Deleting hanging AIOPS service."
    oc -n ${NAMESPACE} delete installation.orchestrator.aiops.ibm.com ibm-cp-watson-aiops
    
    while true; do
      echo "Waiting for service to finish deleting..."
      if [ -z $(oc -n ${NAMESPACE} get installation.orchestrator.aiops.ibm.com | grep ibm-cp-watson-aiops | awk '{print $1}') ]; then
        break
      fi
      sleep $SLEEP_TIME
    done

    echo "Recreating AIOPS service..."
    echo "${CP4AIOPS_SERVICE}" | oc -n ${NAMESPACE} apply -f  -

  fi

  # If the service has been restarted 2 times, it will quit and time out.
  if [ "$run_limit_count" -eq "$RUN_LIMIT" ]; then
    echo 'Run timed out'
    exit 1
  fi
done

echo '=== Installation Complete ==='