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

# waiting for operator to install
sleep 300

POD=""
SECONDS=0
timeout=900
while [[ -z "$POD" ]]; do
  if [ $SECONDS -ge $timeout ]; then
    echo "Timed out after ${timeout} seconds"
    exit 1
  fi
  POD=$(kubectl get pods -n cpd-meta-ops | grep ibm-cp-data-operator | awk '{print $1}')
  echo "Waiting ${POD} to start.."
  sleep 2
done
echo "${POD} started."

# Waiting for operator to setup.
sleep 30

# This needs to occur for all modules
# Check route for image registry if it is not created
if ! oc get route -n openshift-image-registry | awk '{print $1}'| grep -q 'image-registry'; then
  echo "Create image registry route"
  oc create route reencrypt --service=image-registry -n openshift-image-registry
else
  policy=`oc get route -n openshift-image-registry | awk '$1 == "image-registry" {print $5}'`
  if [[ $policy != "reencrypt" ]]; then
  oc delete route image-registry -n openshift-image-registry
  oc create route reencrypt --service=image-registry -n openshift-image-registry
  fi
fi

oc annotate route image-registry --overwrite haproxy.router.openshift.io/balance=source -n openshift-image-registry

install_cpd_service() {
  module_file=$1
  module_name=$2
  service_name=$3

  local failureCount=0

  echo "[DEBUG] Applying..."
  echo "[DEBUG] ${module_file}"

  echo "${module_file}" | oc apply -f -
  # Waiting for cpd service pod to begin.
  sleep 60

  echo "CPD ${module_name} Service Installation Started..."

  # Each retry is 10 seconds   
  for ((retry=0;retry<=9999;retry++)); do

    # Check for Success
    # The following code is taken from get_enpoints.sh, to print what it's getting
    result_txt=$(kubectl logs -n cpd-meta-ops $POD | sed 's/[[:cntrl:]]\[[0-9;]*m//g' | tail -20)
    if echo $result_txt | grep -q "Install/Upgrade for assembly ${module_name} completed successfully"; then
      echo "[INFO] installation was successful"
      break
    elif echo $result_txt | grep -q 'CPD binary has failed'; then
      if [ $failureCount -ge 3 ]; then
        echo "Failed ${faulureCount} times. Quitting, install."
        exit 1
      fi
      failureCount=$((failureCount+1))
      echo "[ERROR] installation not successful, restarting ${module_name} service"
      oc delete cpdservice ${service_name} -n cp4d 
      echo "Redeploying CPD Service"
      echo "${module_file}" | oc apply -f -
      sleep 60
    fi

    # Check for Timeout
    # 60 min timeout
    if [[ ${retry} -eq 360 ]]; then
      echo "Timeout occurred for CP4D ${module_name} install"
      echo "Please use command 'oc get pod ${POD}' to check details"
      oc describe pod ${POD} -n cpd-meta-ops
      oc logs ${POD} -n cpd-meta-ops
      exit 1
    fi

    sleep 10
  done
}

echo "Deploying CPD control plane"
install_cpd_service ${LITE_SERVICE} lite lite-cpdservice

sleep 60

if [ $EMPTY_MODULE_LIST ]; then
  address=$(echo $result_text | sed -n 's#.*\(https*://[^"]*\).*#\1#p')
  if [[ -z $address ]]; then
    echo "[ERROR] failed to get the endpoint address from the logs"
    exit 1
  fi
  echo "[INFO] CPD Endpoint: $address"
else 
  # module_file=$1  
  # module_name=$2
  # service_name=$3 
  if [ $INSTALL_WATSON_KNOWLEDGE_CATALOG ]; then
    echo "Deploying Watson Knowledge Catalog Module"
    install_cpd_service $WKC_SERVICE wkc wkc-cpdservice
  fi
  if [ $INSTALL_WATSON_STUDIO ]; then
    echo "Deploying Watson Studio Module"
    install_cpd_service $WSL_SERVICE wsl wsl-cpdservice
  fi
  if [ $INSTALL_WATSON_MACHINE_LEARNING ]; then
    echo "Deploying Watson Machine Learning Module"
    install_cpd_service $WML_SERVICE wml wml-cpdservice
  fi
  if [ $INSTALL_WATSON_OPEN_SCALE ]; then
    echo "Deploying Watson Open Scale Module"
    install_cpd_service $WOS_SERVICE wos wos-cpdservice
  fi
  if [ $INSTALL_DATA_VIRTUALIZATION ]; then
    echo "Deploying Data Virtualization Module"
    install_cpd_service $DV_SERVICE dv dv-cpdservice
  fi
  if [ $INSTALL_STREAMS ]; then
    echo "Deploying Streams Module"
    install_cpd_service $STEAMS streams streams-cpdservice
  fi
  if [ $INSTALL_ANALYTICS_DASHBOARD ]; then
    echo "Deploying Cognos Dashboard Embedded Module"
    install_cpd_service $CDE_SERVICE cde cde-cpdservice
  fi
  if [ $INSTALL_SPARK ]; then
    echo "Deploying Spark Module"
    install_cpd_service $SPARK spark spark-cpdservice
  fi
  if [ $INSTALL_DB2_WAREHOUSE ]; then
    echo "Deploying DB2 Warehouse Module"
    install_cpd_service $DB2_WAREHOUSE_SERVICE db2wh db2wh-cpdservice
  fi
  if [ $INSTALL_DB2_DATA_GATE ]; then
    echo "Deploying DB2 Data Gate Module"
    install_cpd_service $DB2_DATA_GATE_SERVICE datagate datagate-cpdservice
  fi
  if [ $INSTALL_RSTUDIO ]; then
    echo "Deploying RStudio Module"
    install_cpd_service $RSTUDIO_SERVICE rstudio rstudio-cpdservice
  fi
  if [ $INSTALL_DB2_DATA_MANAGEMENT ]; then
    echo "Deploying DB2 Data Management Module"
    install_cpd_service $DB2_DATA_MNGMT_SERVICE dmc dmc-cpdservice
  fi           
fi

# [[ "$DEBUG" == "false" ]] && exit

# echo "[DEBUG] Job installer '${JOB_NAME}' description."
# kubectl describe job ${JOB_NAME} -n ${NAMESPACE}
# if [[ -n $pod ]]; then
#   echo "[DEBUG] Decription of Pod $pod created by the Job installer:"
#   kubectl describe pod $pod -n ${NAMESPACE}
#   echo "[DEBUG] Log of Pod $pod created by the Job installer:"
#   kubectl logs $pod -n ${NAMESPACE}
# fi
