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
echo "creating namespace cp4i"
kubectl create namespace ${NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

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
create_secret ibm-entitlement-key ${NAMESPACE}



sleep 40

HELM3=$(which helm)
oc get users

mkdir cp4s_cli_install
cloudctl case save -t 1 --case https://github.com/IBM/cloud-pak/raw/master/repo/case/ibm-cp-security-1.0.17.tgz --outputdir ./cp4s_cli_install/ && tar -xf ./cp4s_cli_install/ibm-cp-security-1.0.17.tgz
$(sed -e "s/LDAP_USER_ID/${LDAP_USER_ID}/g" -e "s/ENTITLEMENT_KEY/${DOCKER_REGISTRY_PASS}/g"  ../templates/values.conf > ./ibm-cp-security/inventory/installProduct/files/values.conf)
cloudctl case launch -t 1 --case ibm-cp-security --namespace default  --inventory installProduct --action install --args "--license accept --helm3 ${HELM3} --inputDir ./cp4s_cli_install/"

