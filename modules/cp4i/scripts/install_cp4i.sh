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
# - kubectl

# Optional input parameters with default values:
NAMESPACE=${NAMESPACE:-cp4i}
DEBUG=${DEBUG:-false}
DOCKER_USERNAME=${DOCKER_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed

JOB_NAME="cloud-installer"
WAITING_TIME=5

echo "Waiting for Ingress domain to be created"
while [[ -z $(kubectl get route -n openshift-ingress router-default -o jsonpath='{.spec.host}' 2>/dev/null) ]]; do
  sleep $WAITING_TIME
done

echo "Deploying Catalog Option ${IBM_OPERATOR_CATALOG}"
echo "${IBM_OPERATOR_CATALOG}" | oc apply -f -

# echo "Creating namespace ${NAMESPACE}"
echo "creating namespace ${NAMESPACE}"
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

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
    --namespace=${namespace}
}

create_secret ibm-entitlement-key default
create_secret ibm-entitlement-key openshift-operators
create_secret ibm-entitlement-key $NAMESPACE

sleep 40

echo "Deploying Subscription ${SUBSCRIPTION}"
echo "${SUBSCRIPTION}" | oc apply -f -

echo "Waiting 17minutes for operators to install..."
sleep 1020

if ${ON_VPC}; then
  storage_class="portworx-rwx-gp3-sc"
else
  storage_class="ibmc-file-gold-gid"
fi
PLATFORM_NAVIGATOR=`sed -e "s/STORAGECLASS/${storage_class}/g" ../templates/navigator.yaml`
echo "Deploying Platform Navigator ${PLATFORM_NAVIGATOR}"
sed -e "s/STORAGECLASS/${storage_class}/g" ../templates/navigator.yaml | oc -n ${NAMESPACE} apply -f -

SLEEP_TIME="60"
RUN_LIMIT=200
i=0

while true; do
  if ! STATUS_LONG=$(oc -n ${NAMESPACE} get platformnavigator cp4i-navigator --output=json | jq -c -r '.status'); then
    echo 'Error getting status'
    exit 1
  fi

  echo $STATUS_LONG
  STATUS=$(echo $STATUS_LONG | jq -c -r '.conditions[0].type')

  if [ "$STATUS" == "Ready" ]; then
    break
  fi
  
  if [ "$STATUS" == "Failed" ]; then
    echo '=== Installation has failed ==='
    exit 1
  fi
  
  echo "Sleeping $SLEEP_TIME seconds..."
  sleep $SLEEP_TIME
  
  (( i++ ))
  if [ "$i" -eq "$RUN_LIMIT" ]; then
    echo 'Timed out'
    exit 1
  fi
done
