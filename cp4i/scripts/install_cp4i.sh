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
# kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# echo "Creating ServiceAccount cpdinstall"
# kubectl create sa cpdinstall -n kube-system --dry-run=client -o yaml | kubectl apply -f -
# kubectl create sa cpdinstall -n ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

# echo "${SCC_ZENUID_CONTENT}" | kubectl apply -f -
# oc adm policy add-scc-to-user ${NAMESPACE}-zenuid system:serviceaccount:${NAMESPACE}:cpdinstall
# oc adm policy add-scc-to-user anyuid system:serviceaccount:${NAMESPACE}:icpd-anyuid-sa
# oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:${NAMESPACE}:cpdinstall
# oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:kube-system:cpdinstall

# if ! oc get route -n openshift-image-registry | awk '{print $1}'| grep -q 'image-registry'; then
#   echo "Creating image registry route"
#   oc create route reencrypt --service=image-registry -n openshift-image-registry
# else
#   policy=`oc get route -n openshift-image-registry | awk '$1 == "image-registry" {print $5}'`
#   if [[ $policy != "reencrypt" ]]; then
#     echo "Recreating image registry route"
#     oc delete route image-registry -n openshift-image-registry
#     oc create route reencrypt --service=image-registry -n openshift-image-registry
#   fi
# fi

# echo "Ensure the image registry is the default route"
# kubectl patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"defaultRoute":true}}'
# oc annotate route image-registry --overwrite haproxy.router.openshift.io/balance=source -n openshift-image-registry

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

  # [[ "${link}" != "no-link" ]] && oc secrets -n ${namespace} link cpdinstall icp4d-anyuid-docker-pull --for=pull
}

create_secret ibm-entitlement-key default
create_secret ibm-entitlement-key openshift-operators

# create_secret icp4d-anyuid-docker-pull kube-system
# create_secret sa-${NAMESPACE} ${NAMESPACE} no-link

sleep 40

echo "Deploying Subscription ${SUBSCRIPTION}"
echo "${SUBSCRIPTION}" | oc apply -f -

sleep 120

echo "Deploying Platform Navigator ${PLATFORM_NAVIGATOR}"
echo "${PLATFORM_NAVIGATOR}" | oc apply -f -

# The following code is taken from get_enpoints.sh, to print what it's getting
# result_txt=$(kubectl logs -n ${NAMESPACE} $pod | sed 's/[[:cntrl:]]\[[0-9;]*m//g' | tail -20)
# if ! echo $result_txt | grep -q 'Installation of assembly lite is successfully completed'; then
#   echo "[ERROR] a successful installation was not found from the logs"
# fi

# echo "[DEBUG] Latest lines from logs:"
# echo "[DEBUG] $result_txt"

# address=$(echo $result_txt | sed 's|.*Access Cloud Pak for Data console using the address: \(.*\) .*|\1|')
# if [[ -z $address ]]; then
#   echo "[ERROR] failed to get the endpoint address from the logs"
# fi
# echo "[INFO] CPD Endpoint: https://$address"

# [[ "$DEBUG" == "false" ]] && exit

# echo "[DEBUG] Job installer '${JOB_NAME}' description."
# kubectl describe job ${JOB_NAME} -n ${NAMESPACE}
# if [[ -n $pod ]]; then
#   echo "[DEBUG] Decription of Pod $pod created by the Job installer:"
#   kubectl describe pod $pod -n ${NAMESPACE}
#   echo "[DEBUG] Log of Pod $pod created by the Job installer:"
#   kubectl logs $pod -n ${NAMESPACE}
# fi
