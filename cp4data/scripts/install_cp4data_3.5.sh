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
DOCKER_USERNAME=${DOCKER_USERNAME:-ekey}
# TODO: Verify which is the default docker username: ekey or cp
# DOCKER_USERNAME=${DOCKER_USERNAME:-cp}
DOCKER_REGISTRY=${DOCKER_REGISTRY:-cp.icr.io/cp/cpd}
# TODO: For non-production, use:
# DOCKER_REGISTRY="cp.stg.icr.io/cp/cpd"

# By default the persistent volume, the data, and your physical file storage device are deleted when CP4D is deprovisioned or the cluster destroyed.
# TODO: Other values for STORAGE_CLASS_NAME could be:
# - To retain/persist the storage after destroy the cluster, use 'ibmc-file-retain-gold-gid'
# - If using Portworx, use 'portworx-shared-gp3'
# - If using OpenShift Container Storage, use 'ocs-storagecluster-cephfs'


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
kubectl patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"defaultRoute":true}}'
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
  sleep 5
  pod=$(kubectl get pods --selector=job-name=cloud-installer -l app=cp4data-installer -n ${NAMESPACE} --output=jsonpath='{.items[*].metadata.name}')
done

echo "The installer job triggered the pod ${pod}"

echo "Waiting for the job to complete or timeout in 2hrs"
kubectl wait \
  --for=condition=Complete \
  --timeout=2h \
  --namespace=${NAMESPACE} \
  job/cloud-installer

# Just for debugging, feel free to remove if annoying or not required in the logs
echo "[DEBUG] Job installer 'cp4data-installer' description."
kubectl describe job cp4data-installer -n ${NAMESPACE}
[[ $? -ne 0 ]] && echo "[DEBUG] This error may be because the Job finished successfully"
if [[ -n $pod ]]; then
  echo "[DEBUG] Decription of Pod $pod created by the Job installer:"
  kubectl describe pod $pod -n ${NAMESPACE}
  echo "[DEBUG] Log of Pod $pod created by the Job installer:"
  kubectl logs $pod -n ${NAMESPACE}
fi
