#!/bin/sh

# Required input parameters
# - KUBECONFIG : Not used directly but required by oc
# - STORAGE_CLASS_NAME
# - DOCKER_REGISTRY_PASS
# - DOCKER_USER_EMAIL
# - STORAGE_CLASS_CONTENT
# - INSTALLER_SENSITIVE_DATA
# - INSTALLER_JOB_CONTENT
# - SCC_ZENUID_CONTENT

# Software requirements:
# - oc
# - kubectl

# Optional input parameters with default values:
DEBUG=${DEBUG:-false}
DOCKER_USERNAME=${DOCKER_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed

JOB_NAME="cloud-installer"
WAITING_TIME=5

echo "Waiting for Ingress domain to be created"
while [[ -z $(kubectl get route -n openshift-ingress router-default -o jsonpath='{.spec.host}' 2>/dev/null) ]]; do
  sleep $WAITING_TIME
done

# echo "Creating namespace ${NAMESPACE}"
echo "creating namespace ${NAMESPACE}"
kubectl create namespace ${NAMESPACE} 

create_secret() {
  secret_name=$1
  namespace=$2
  link=$3

  echo "Creating secret ${secret_name} on ${namespace} from entitlement key"
  kubectl create secret docker-registry ${secret_name} \
    --docker-server=${DOCKER_REGISTRY} \
    --docker-username=${DOCKER_USERNAME} \
    --docker-password=${DOCKER_REGISTRY_PASS} \
    --docker-email=${DOCKER_USER_EMAIL} \
    --namespace=${NAMESPACE}

  # [[ "${link}" != "no-link" ]] && kubectl secrets -n ${namespace} link cpdinstall icp4d-anyuid-docker-pull --for=pull
}

create_secret ibm-entitlement-key ${NAMESPACE}

#create_secret ibm-isc-pull-secret ${NAMESPACE}

echo "Deploying Catalog Option ${OPERATOR_CATALOG}"
echo "${OPERATOR_CATALOG}" | kubectl apply -f -

# echo "Deploying Catalog Option ${COMMON_SERVICES_CATALOG}"
# echo "${COMMON_SERVICES_CATALOG}" | kubectl apply -f -

echo "Deploying Operator Group ${OPERATOR_GROUP}"
echo "${OPERATOR_GROUP}" | kubectl apply -f -

# echo "Deploying Operator Group ${KNATIVE_SUBSCRIPTION}"
# echo "${KNATIVE_SUBSCRIPTION}" | kubectl apply -f -

# sleep 160

# echo "Deploying Operator Group ${KNATIVE}"
# echo "${KNATIVE}" | kubectl apply -f -

echo "Deploying Subscription ${SUBSCRIPTION}"
echo "${SUBSCRIPTION}" | kubectl apply -f -

sleep 60

echo "Deploying Threat Management CSV ${CP4S_THREAT_MANAGEMENT}"
echo "${CP4S_THREAT_MANAGEMENT}" | kubectl apply -f -

# TODO  while kubectl -n ${NAMESPACE} get cpdservice ${SERVICE}-cpdservice --output=json | jq -c -r '.status'