#!/bin/sh

SECRET_NAME="icpa-installer-pull-secret"
PATCH_CM_NAME="icpa-patch"
KUBECONFIG_CM_NAME="icpa-kubeconfig"
ICPA_DATA_CM_NAME="icpa-config-data"
ICPA_JOB_NAME="icpa-installer"

echo "Creating namespace ${ICPA_NAMESPACE}"
kubectl create namespace ${ICPA_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

echo "Ensure that the image registry has a valid route for IBM Cloud Pak for Multicloud Management images"
kubectl patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"defaultRoute":true}}'

echo "Create secret from entitlement key"
kubectl create secret docker-registry ${SECRET_NAME} \
  --docker-username=${ICPA_ENTITLED_REGISTRY_USER} \
  --docker-password=${ICPA_ENTITLED_REGISTRY_KEY} \
  --docker-email=${ICPA_ENTITLED_REGISTRY_USER_EMAIL} \
  --docker-server=${ICPA_ENTITLED_REGISTRY} \
  --namespace=${ICPA_NAMESPACE} \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Create ConfigMap with the shell code to patch the ICPA installer"
kubectl create configmap ${PATCH_CM_NAME} \
  --from-file=${ICPA_INSTALLER_PATCH_FILE} \
  --namespace=${ICPA_NAMESPACE} \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Create ConfigMap with Kubeconfig file content"
kubectl create configmap ${KUBECONFIG_CM_NAME} \
  --from-file=config=${KUBECONFIG} \
  --namespace=${ICPA_NAMESPACE} \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Create ConfigMap with configuration files for the ICPA installer"
kubectl create configmap ${ICPA_DATA_CM_NAME} \
  --from-file=${ICPA_DATA_CONFIG_DIR} \
  --namespace=${ICPA_NAMESPACE} \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Create and execute Job to install ICPA"
echo "${ICPA_INSTALLER_JOB_CONTENT}" | kubectl apply -f -

echo "Waiting for a pod to be created by the job"
while [[ -z $pod ]]; do
  sleep 1
  pod=$(kubectl get pods --selector=job-name=${ICPA_JOB_NAME} -n ${ICPA_NAMESPACE} --output=jsonpath='{.items[*].metadata.name}')
done

echo "The job ${ICPA_JOB_NAME} triggered the pod ${pod}"

echo "Waiting for the job to complete or timeout in 2hrs"
kubectl wait \
  --for=condition=Complete \
  --timeout=2h \
  --namespace=${ICPA_NAMESPACE} \
  job/${ICPA_JOB_NAME}
