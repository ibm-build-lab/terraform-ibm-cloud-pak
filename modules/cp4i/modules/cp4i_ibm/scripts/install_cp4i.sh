#!/bin/sh

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

# echo "Creating namespace ${NAMESPACE}"
echo "creating namespace ${NAMESPACE}"
kubectl create namespace ${NAMESPACE}

echo "Deploying Catalog Option ${CATALOG_CONTENT}"
kubectl apply -f -<<EOF
${CATALOG_CONTENT}
EOF

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

echo "Deploying Subscription ${SUBSCRIPTION_CONTENT}"
kubectl apply -f -<<EOF
${SUBSCRIPTION_CONTENT}
EOF

echo "Waiting 10 minutes for operators to install..."
sleep 600

echo "Deploying Platform Navigator ${NAVIGATOR_CONTENT}"
kubectl apply -n ${NAMESPACE} -f -<<EOF
${NAVIGATOR_CONTENT}
EOF

SLEEP_TIME="60"
RUN_LIMIT=200
i=0

while true; do
  if ! STATUS_LONG=$(kubectl -n ${NAMESPACE} get platformnavigator cp4i-navigator --output=json | jq -c -r '.status'); then
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
