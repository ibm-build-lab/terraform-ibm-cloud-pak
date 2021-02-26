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
NAMESPACE=${default}
FORCE=${FORCE:-false} # Delete the job installer and execute it again
DEBUG=${DEBUG:-false}
DOCKER_USERNAME=${DOCKER_USERNAME:-cp}
# The default docker username is cp, however the original scrip uses: ekey
# DOCKER_USERNAME=${DOCKER_USERNAME:-ekey}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io}  # adjust this if needed
# For non-production, use:
# DOCKER_REGISTRY="cp.stg.icr.io/cp/cpd"

# By default the persistent volume, the data, and your physical file storage device are deleted when CP4D is deprovisioned or the cluster destroyed.
# TODO: Other values for STORAGE_CLASS_NAME could be:
# - To retain/persist the storage after destroy the cluster, use 'ibmc-file-retain-gold-gid'
# - If using Portworx, use 'portworx-shared-gp3'
# - If using OpenShift Container Storage, use 'ocs-storagecluster-cephfs'

JOB_NAME="cloud-installer"
WAITING_TIME=5

echo "Waiting for Ingress domain to be created"
while [[ -z $(kubectl get route -n openshift-ingress router-default -o jsonpath='{.spec.host}' 2>/dev/null) ]]; do
  sleep $WAITING_TIME
done

echo "Deploying Catalog Option ${IBM_OPERATOR_CATALOG}"
echo "${IBM_OPERATOR_CATALOG}" | oc apply -f -

echo "Deploying Catalog Option ${OPENCLOUD_OPERATOR_CATALOG}"
echo "${OPENCLOUD_OPERATOR_CATALOG}" | oc apply -f -

# echo "Creating namespace ${NAMESPACE}"
kubectl create namespace cp4d --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace cpd-meta-ops --dry-run=client -o yaml | kubectl apply -f -

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

# create_secret ibm-entitlement-key default
create_secret ibm-entitlement-key cpd-meta-ops
create_secret ibm-entitlement-key cp4d

sleep 40

echo "Creating Operator Group"
echo "${OPERATOR_GROUP}" | oc apply -f -

echo "Deploying Subscription ${SUBSCRIPTION}"
echo "${SUBSCRIPTION}" | oc apply -f -

# echo "Waiting for the job to complete or timeout in 2hrs"
# kubectl wait \
#   --for=condition=Complete \
#   --timeout=2h \
#   --namespace=${NAMESPACE} \
#   operator/${JOB_NAME}

echo "Deploying CPD Service"
echo "${CPD_SERVICE}" | oc apply -f -


POD=$(kubectl get pods -n cpd-meta-ops | grep ibm-cp-data-operator | awk '{print $1}')
if [[ ${POD} != "" ]]; then
echo "Waiting for ${POD} is running"
  while [[ -z "$POD" ]]; do
      echo "Waiting for pod to start."
      sleep 2
  done
fi
    
echo "Installation Started..."
# Each retry is 10 seconds   
for ((retry=0;retry<=9999;retry++)); do

  # Check for Success
  # The following code is taken from get_enpoints.sh, to print what it's getting
  result_txt=$(kubectl logs -n cpd-meta-ops $POD | sed 's/[[:cntrl:]]\[[0-9;]*m//g' | tail -20)
  if echo $result_txt | grep -q 'Install/Upgrade for assembly lite completed successfully'; then
    echo "[INFO] installation was successful"
    break
  elif echo $result_txt | grep -q 'CPD binary has failed'; then
    echo "[ERROR] installation not successful"
    exit 1
  fi

  # Check for Timeout
  # 30 min timeout
  if [[ ${retry} -eq 180 ]]; then
    echo "Timeout occurred for CP4D install"
    echo "Please use command 'oc get pod ${POD}' to check details"
    oc describe pod ${POD} -n cpd-meta-ops
    oc logs ${POD} -n cpd-meta-ops
    exit 1
  fi

  sleep 10
done


# echo "[DEBUG] Latest lines from logs:"
# echo "[DEBUG] $result_txt"

address=$(echo $result_txt | sed -n 's#.*\(https*://[^"]*\).*#\1#p')
if [[ -z $address ]]; then
  echo "[ERROR] failed to get the endpoint address from the logs"
fi
echo "[INFO] CPD Endpoint: $address"

# [[ "$DEBUG" == "false" ]] && exit

# echo "[DEBUG] Job installer '${JOB_NAME}' description."
# kubectl describe job ${JOB_NAME} -n ${NAMESPACE}
# if [[ -n $pod ]]; then
#   echo "[DEBUG] Decription of Pod $pod created by the Job installer:"
#   kubectl describe pod $pod -n ${NAMESPACE}
#   echo "[DEBUG] Log of Pod $pod created by the Job installer:"
#   kubectl logs $pod -n ${NAMESPACE}
# fi
