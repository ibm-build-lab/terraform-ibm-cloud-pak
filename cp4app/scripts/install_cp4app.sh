#!/bin/sh

echo "Creating namespace ${ICPA_NAMESPACE}"
kubectl create namespace ${ICPA_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

echo "Ensure that the image registry has a valid route for IBM Cloud Pak for Multicloud Management images"
kubectl patch configs.imageregistry.operator.openshift.io/cluster --type merge -p '{"spec":{"defaultRoute":true}}'

echo "Create secret from entitlement key"
kubectl create secret docker-registry icpa-installer-pull-secret \
  --docker-username=${ICPA_ENTITLED_REGISTRY_USER} \
  --docker-password=${ICPA_ENTITLED_REGISTRY_KEY} \
  --docker-email=${ICPA_ENTITLED_REGISTRY_USER_EMAIL} \
  --docker-server=${ICPA_ENTITLED_REGISTRY} \
  --namespace=${ICPA_NAMESPACE} \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Create ConfigMap with the shell code to patch the ICPA installer"
kubectl create configmap icpa-config \
  --from-file=${ICPA_INSTALLER_PATCH_FILE} \
  --namespace=${ICPA_NAMESPACE} \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Create ConfigMap with Kubeconfig file content"
kubectl create configmap icpa-config \
  --from-file=$(dirname $KUBECONFIG) \
  --namespace=${ICPA_NAMESPACE} \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Create ConfigMap with configuration files for the ICPA installer"
kubectl create configmap icpa-config-data \
  --from-file=${ICPA_DATA_CONFIG_DIR} \
  --namespace=${ICPA_NAMESPACE} \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Create and execute Job to install ICPA"
echo "${ICPA_INSTALLER_JOB_CONTENT}" | kubectl apply -f -

echo "Waiting for the job to complete"
kubectl wait --for=condition=Complete --timeout=2h job/icpa-installer
