#!/bin/bash
###############################################################################
#
# Licensed Materials - Property of IBM
#
# (C) Copyright IBM Corp. 2021. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
###############################################################################
CUR_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PARENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"
K8S_CMD=kubectl

###### Create the namespace
echo
echo "Creating \"${CP4BA_PROJECT_NAME}\" project ... "
${K8S_CMD} create namespace "${CP4BA_PROJECT_NAME}"
echo

###### Create the secrets
echo -e "\x1B[1mCreating secret \"admin.registrykey\" in ${CP4BA_PROJECT_NAME}...\n\x1B[0m"
CREATE_SECRET_RESULT=$(${K8S_CMD} create secret docker-registry admin.registrykey -n "${CP4BA_PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${ENTITLED_REGISTRY_EMAIL}")
sleep 5

if [[ ${CREATE_SECRET_RESULT} ]]; then
    echo -e "\033[1;32m \"admin.registrykey\" secret has been created\x1B[0m"
fi

echo
echo -e "\x1B[1mCreating secret \"ibm-entitlement-key\" in ${CP4BA_PROJECT_NAME}...\n\x1B[0m"
CREATE_SECRET_RESULT=$(${K8S_CMD} create secret docker-registry ibm-entitlement-key -n "${CP4BA_PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${ENTITLED_REGISTRY_EMAIL}")
sleep 5

if [[ ${CREATE_SECRET_RESULT} ]]; then
    echo -e "\033[1;32m \"ibm-entitlement-key\" secret has been created\x1B[0m"
fi
echo

# echo -e "\x1B[1mCreating remaining secrets \n${SECRETS_CONTENT}...\n\x1B[0m"
echo -e "\x1B[1mCreating remaining secrets...\n\x1B[0m"
kubectl apply -n "${CP4BA_PROJECT_NAME}" -f -<<EOF
${SECRETS_CONTENT}
EOF

###### Create storage
#echo -e "\x1B[1mCreating storage classes...\x1B[0m"
#kubectl apply -f ${CP4BA_STORAGE_CLASS_FILE}

#! PVs
echo
echo -e "\x1B[1m Creating the \"operator-shared-pv\" Persistent Volumes (PVs) ...\x1B[0m"
cat "${OPERATOR_SHARED_PV_FILE}"
CREATE_PVC_RESULT=$(kubectl apply -f "${OPERATOR_SHARED_PV_FILE}" --validate=false)

if [[ $CREATE_PVC_RESULT ]]; then
    echo -e "\x1B[1;34m The \"operator-shared-pv\" Persistent Volume has been created.\x1B[0m"
else
    echo -e "\x1B[1;31mFailed\x1B[0m"
fi

echo
echo -e "\x1B[1m Creating the \"cp4a-shared-log-pv\" Persistent Volumes (PVs) ...\x1B[0m"
cat "${SHARED_LOG_PV_FILE}"
CREATE_PVC_RESULT=$(kubectl apply -f "${SHARED_LOG_PV_FILE}" --validate=false)

if [[ $CREATE_PVC_RESULT ]]; then
    echo -e "\x1B[1;34m The \"cp4a-shared-log-pv\" Persistent Volume has been created.\x1B[0m"
else
    echo -e "\x1B[1;31mFailed\x1B[0m"
fi


#!    PVCs
echo
echo -e "\x1B[1m Creating \"operator-shared-pvc\" Persistent Volume Claim (PVC) ...\x1B[0m"
cat "${OPERATOR_SHARED_PVC_FILE}"
CREATE_PVC_RESULT=$(kubectl apply -f "${OPERATOR_SHARED_PVC_FILE}" --validate=false)

if [[ $CREATE_PVC_RESULT ]]; then
    echo -e "\x1B[1;34m The \"operator-shared-pvc\"  Persistent Volume Claims has been created.\x1B[0m"
else
    echo -e "\x1B[1;31mFailed\x1B[0m"
fi

echo
echo -e "\x1B[1m Creating \"cp4a-shared-log-pvc\" Persistent Volume Claim (PVC) ...\x1B[0m"
cat "${SHARED_LOG_PVC_FILE}"
CREATE_PVC_RESULT=$(kubectl apply -f "${SHARED_LOG_PVC_FILE}" --validate=false)

if [[ $CREATE_PVC_RESULT ]]; then
    echo -e "\x1B[1;34m The \"cp4a-shared-log-pvc\" Persistent Volume Claim has been created.\x1B[0m"
else
    echo -e "\x1B[1;31mFailed\x1B[0m"
fi


# Check Operator Persistent Volume status every 5 seconds (max 10 minutes) until allocate.
ATTEMPTS=0
TIMEOUT=60
printf "\n"
echo -e "\x1B[1mWaiting for the persistent volumes to be ready...\x1B[0m"
until (${K8S_CMD} get pvc -n "${CP4BA_PROJECT_NAME}" | grep cp4a-shared-log-pvc | grep "Bound") || [ $ATTEMPTS -eq $TIMEOUT ] ; do
    ATTEMPTS=$((ATTEMPTS + 1))
    echo -e "......"
    sleep 10
    if [ $ATTEMPTS -eq $TIMEOUT ] ; then
        echo -e "\x1B[1;31mFailed: Run the following command to check the claim '${K8S_CMD} describe pvc cp4a-shared-log-pvc'\x1B[0m"
        exit 1
    fi
done
if [ $ATTEMPTS -lt $TIMEOUT ] ; then
    echo -e "\x1B[1;34m The Persistent Volume Claim is successfully bound\x1B[0m"
fi
echo

ATTEMPTS=0
TIMEOUT=60
echo -e "\x1B[1mWaiting for the persistent volumes to be ready...\x1B[0m"
until (${K8S_CMD} get pvc -n "${CP4BA_PROJECT_NAME}" | grep operator-shared-pvc | grep "Bound") || [ $ATTEMPTS -eq $TIMEOUT ] ; do
    ATTEMPTS=$((ATTEMPTS + 1))
    echo -e "......"
    sleep 10
    if [ $ATTEMPTS -eq $TIMEOUT ] ; then
        echo -e "\x1B[1;31mFailed: Run the following command to check the claim '${K8S_CMD} describe pvc operator-shared-pvc'\x1B[0m"
        exit 1
    fi
done
if [ $ATTEMPTS -lt $TIMEOUT ] ; then
    echo -e "\x1B[1;34m The Persistent Volume Claim is successfully bound\x1B[0m"
fi
echo

###### Add the CatalogSource resources to Operator Hub
# Creating roles
echo -e "\x1B[1mCreating roles ...\x1B[0m"
cat "${ROLES_FILE}"
${K8S_CMD} apply -f "${ROLES_FILE}" -n "${CP4BA_PROJECT_NAME}"
echo

# Creating roles
echo -e "\x1B[1mCreating role binding ...\x1B[0m"
cat "${ROLE_BINDING_FILE}"
${K8S_CMD} apply -f "${ROLE_BINDING_FILE}" -n "${CP4BA_PROJECT_NAME}"
echo

# Deploy common-service
echo -e "\x1B[1m Creating common-service namespace ...\x1B[0m"
${K8S_CMD} create namespace common-service
echo


# CREATING OPERATOR GROUP
echo -e "\x1B[1m Creating Operator Group ...\x1B[0m"
cat "${OPERATOR_GROUP_FILE}"
${K8S_CMD} apply -f "${OPERATOR_GROUP_FILE}"
echo

# Add the CatalogSource resources to Operator Hub
echo -e "\x1B[1m Creating the Catalog Source ...\x1B[0m"
cat "${CATALOG_SOURCE_FILE}"
${K8S_CMD} apply -f "${CATALOG_SOURCE_FILE}"
sleep 10
echo ""

echo -e "\x1B[1m Deploying common-service ...\x1B[0m"
cat "${COMMON_SERVICE_FILE}"
${K8S_CMD} apply -f "${COMMON_SERVICE_FILE}"
sleep 100
echo

echo -e "\x1B[1m Creating the AutomationUIConfig ...\x1B[0m"
kubectl apply -f "${AUTO_UI_CONFIG_FILE_CONTENT}"
cat "${AUTO_UI_CONFIG_FILE_CONTENT}"
sleep 10
echo

echo -e "\x1B[1m Creating the Cartridge ...\x1B[0m"
kubectl apply -f "${CARTRIDGE_FILE_CONTENT}"
cat "${CARTRIDGE_FILE_CONTENT}"
sleep 10
echo


# Create subscription to Business Automation Operator
echo -e "\x1B[1m Creating the Subscription ...\x1B[0m"
cat "${CP4BA_SUBSCRIPTION_FILE}"
${K8S_CMD} apply -f "${CP4BA_SUBSCRIPTION_FILE}" -n "${CP4BA_PROJECT_NAME}"
sleep 100
echo

# Create Deployment Credentials
echo -e "\x1B[1mCreating the Deployment Credentials ...\x1B[0m"
cat "${CP4BA_DEPLOYMENT_CREDENTIALS_FILE}"
${K8S_CMD} apply -n "${CP4BA_PROJECT_NAME}" -f "${CP4BA_DEPLOYMENT_CREDENTIALS_FILE}"
echo

# Create Deployment
echo -e "\x1B[1mCreating the Deployment ...\x1B[0m"
${K8S_CMD} apply -n "${CP4BA_PROJECT_NAME}" -f "${CP4BA_DEPLOYMENT_CONTENT}" --validate=false
cat "${CP4BA_DEPLOYMENT_CONTENT}"

echo

${K8S_CMD} get pods -n openshift-marketplace | grep ibm-cp4a-operator
result=$?
counter=0
while [[ "${result}" -ne 0 ]]
do
    if [[ $counter -gt 20 ]]; then
        echo "The CP4BA Operator was not created within ten minutes; please attempt to install the product again."
        exit 1
    fi
    counter=$((counter + 1))
    echo "Waiting for CP4BA operator pod to provision"
    sleep 30;
    ${K8S_CMD} get pods -n openshift-marketplace | grep ibm-cp4a-operator
    result=$?
done




