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
NAMESPACE=${NAMESPACE:-cloudpak4data}
FORCE=${FORCE:-false} # Delete the job installer and execute it again
DEBUG=${DEBUG:-false}
DOCKER_USERNAME=${DOCKER_USERNAME:-cp}
# The default docker username is cp, however the original scrip uses: ekey
# DOCKER_USERNAME=${DOCKER_USERNAME:-ekey}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io/cp/cpd}
# For non-production, use:
# DOCKER_REGISTRY="cp.stg.icr.io/cp/cpd"

# By default the persistent volume, the data, and your physical file storage device are deleted when CP4D is deprovisioned or the cluster destroyed.
# TODO: Other values for STORAGE_CLASS_NAME could be:
# - To retain/persist the storage after destroy the cluster, use 'ibmc-file-retain-gold-gid'
# - If using Portworx, use 'portworx-shared-gp3'
# - If using OpenShift Container Storage, use 'ocs-storagecluster-cephfs'

# This script is based on the CP4D install script located in the CP4D Public Catalog.
# To download the script:
#   1. Go to: https://github.com/IBM/cloud-pak/tree/master/repo/case/ibm-cp-datacore
#   2. Locate and go to the version to use, or (recomemnded) the latest version
#   3. Download and unzip the TGZ file
#      Optionally, you may also download it from this URL replacing the version number
#      https://github.com/IBM/cloud-pak/blob/master/repo/case/ibm-cp-datacore-1.3.1.tgz
#   4. Go to the file: ./inventory/ibmcloudEnablement/files/install/install.sh
#      Part of the initial code is also located in ./inventory/ibmcloudEnablement/files/preInstall/pre-install.sh


JOB_NAME="cloud-installer"
WAITING_TIME=5

echo "Waiting for Ingress domain to be created"
while [[ -z $(kubectl get route -n openshift-ingress router-default -o jsonpath='{.spec.host}' 2>/dev/null) ]]; do
  sleep $WAITING_TIME
done

if [[ "$FORCE" == "true" ]]; then
  echo "[WARN] Forcing the execution of the job installer"
  kubectl delete job -n ${NAMESPACE} ${JOB_NAME}
  # if [[ $? -eq 0 ]]; then
  #   echo "[WARN] deleting the job installer"
  #   kubectl wait --for=delete --namespace=${NAMESPACE} --timeout=10m job/${JOB_NAME}
  # else
  #   echo "[WARN] the job installer was not found or was not created"
  # fi
fi

if [[ ${STORAGE_CLASS_NAME} == "portworx-shared-gp3" ]]; then
  echo "Checking Portworx storage is configured in the cluster"
  if ! oc get sc | awk '{print $2}' | grep -q 'kubernetes.io/portworx-volume'; then
    echo "[ERROR] Portworx storage is not configured on this cluster"
    exit 1
  fi
else
  echo "Creating StorageClass ${STORAGE_CLASS_NAME}"
  echo "${STORAGE_CLASS_CONTENT}" | kubectl apply -f -
fi

echo "Creating namespace ${NAMESPACE}"
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

echo "Creating ServiceAccount cpdinstall"
kubectl create sa cpdinstall -n kube-system --dry-run=client -o yaml | kubectl apply -f -
kubectl create sa cpdinstall -n ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

echo "${SCC_ZENUID_CONTENT}" | kubectl apply -f -
oc adm policy add-scc-to-user ${NAMESPACE}-zenuid system:serviceaccount:${NAMESPACE}:cpdinstall
oc adm policy add-scc-to-user anyuid system:serviceaccount:${NAMESPACE}:icpd-anyuid-sa
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:${NAMESPACE}:cpdinstall
oc adm policy add-cluster-role-to-user cluster-admin system:serviceaccount:kube-system:cpdinstall

if ! oc get route -n openshift-image-registry | awk '{print $1}'| grep -q 'image-registry'; then
  echo "Creating image registry route"
  oc create route reencrypt --service=image-registry -n openshift-image-registry
else
  policy=`oc get route -n openshift-image-registry | awk '$1 == "image-registry" {print $5}'`
  if [[ $policy != "reencrypt" ]]; then
    echo "Recreating image registry route"
    oc delete route image-registry -n openshift-image-registry
    oc create route reencrypt --service=image-registry -n openshift-image-registry
  fi
fi

# echo "Ensure the image registry is the default route"
# kubectl patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"defaultRoute":true}}'
oc annotate route image-registry --overwrite haproxy.router.openshift.io/balance=source -n openshift-image-registry

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
    --namespace=${namespace} \
    --dry-run=client -o yaml | kubectl apply -f -

  [[ "${link}" != "no-link" ]] && oc secrets -n ${namespace} link cpdinstall icp4d-anyuid-docker-pull --for=pull
}

oc delete secret icp4d-anyuid-docker-pull -n kube-system
create_secret icp4d-anyuid-docker-pull ${NAMESPACE}
create_secret icp4d-anyuid-docker-pull kube-system
create_secret sa-${NAMESPACE} ${NAMESPACE} no-link

echo "Creating the job installer"
echo "${INSTALLER_SENSITIVE_DATA}" | kubectl apply --namespace ${NAMESPACE} -f -
echo "${INSTALLER_JOB_CONTENT}" | kubectl apply --namespace ${NAMESPACE} -f -
if [[ $? -ne 0 ]]; then
  echo "[ERROR] Fail to create the job installer"
  exit 1
fi

echo "Waiting for installer pod to be created by the job"
while [[ -z $pod ]]; do
  sleep $WAITING_TIME
  pod=$(kubectl get pods --selector=job-name=${JOB_NAME} -l app=cp4data-installer -n ${NAMESPACE} --output=jsonpath='{.items[*].metadata.name}')
done

echo "The installer job triggered the pod ${pod}"

echo "Waiting for the job to complete or timeout in 2hrs"
kubectl wait \
  --for=condition=Complete \
  --timeout=2h \
  --namespace=${NAMESPACE} \
  job/${JOB_NAME}

# The following code is taken from get_enpoints.sh, to print what it's getting
result_txt=$(kubectl logs -n ${NAMESPACE} $pod | sed 's/[[:cntrl:]]\[[0-9;]*m//g' | tail -20)
if ! echo $result_txt | grep -q 'Installation of assembly lite is successfully completed'; then
  echo "[ERROR] a successful installation was not found from the logs"
fi

echo "[DEBUG] Latest lines from logs:"
echo "[DEBUG] $result_txt"

address=$(echo $result_txt | sed 's|.*Access Cloud Pak for Data console using the address: \(.*\) .*|\1|')
if [[ -z $address ]]; then
  echo "[ERROR] failed to get the endpoint address from the logs"
fi
echo "[INFO] CPD Endpoint: https://$address"

[[ "$DEBUG" == "false" ]] && exit

echo "[DEBUG] Job installer '${JOB_NAME}' description."
kubectl describe job ${JOB_NAME} -n ${NAMESPACE}
if [[ -n $pod ]]; then
  echo "[DEBUG] Decription of Pod $pod created by the Job installer:"
  kubectl describe pod $pod -n ${NAMESPACE}
  echo "[DEBUG] Log of Pod $pod created by the Job installer:"
  kubectl logs $pod -n ${NAMESPACE}
fi
