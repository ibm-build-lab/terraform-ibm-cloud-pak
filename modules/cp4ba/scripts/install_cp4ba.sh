#!/bin/bash
# set -x
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
#
K8S_CMD=kubectl
OC_CMD=oc

echo
echo "Creating \"${CP4BA_PROJECT_NAME}\" project ... "
${K8S_CMD} create namespace "${CP4BA_PROJECT_NAME}"
echo

# Create the secrets
echo -e "\x1B[1mCreating secret \"admin.registrykey\" in ${CP4BA_PROJECT_NAME} for CP4BA ...\n\x1B[0m"
CREATE_SECRET_RESULT=$(${K8S_CMD} create secret docker-registry admin.registrykey -n "${CP4BA_PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${ENTITLED_REGISTRY_EMAIL}")
sleep 5

if [[ ${CREATE_SECRET_RESULT} ]]; then
    echo -e "\033[1;32m \"admin.registrykey\" secret has been created\x1B[0m"
fi

echo
echo -e "\x1B[1mCreating secret \"ibm-entitlement-key\" in ${CP4BA_PROJECT_NAME} for CP4BA ...\n\x1B[0m"
CREATE_SECRET_RESULT=$(${K8S_CMD} create secret docker-registry ibm-entitlement-key -n "${CP4BA_PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${ENTITLED_REGISTRY_EMAIL}")
sleep 5

if [[ ${CREATE_SECRET_RESULT} ]]; then
    echo -e "\033[1;32m \"ibm-entitlement-key\" secret has been created\x1B[0m"
fi
echo

# echo -e "\x1B[1mCreating remaining secrets \n${SECRETS_CONTENT}...\n\x1B[0m"
echo -e "\x1B[1mCreating remaining secrets...\n\x1B[0m"
kubectl apply -n ${CP4BA_PROJECT_NAME} -f -<<EOF
${SECRETS_CONTENT}
EOF

echo -e "\x1B[1mCreating the Persistent Volumes Claim (PVC)...\x1B[0m"
cat ${OPERATOR_PVC_FILE}
CREATE_PVC_RESULT=$(kubectl -n ${CP4BA_PROJECT_NAME} apply -f ${OPERATOR_PVC_FILE})

if [[ $CREATE_PVC_RESULT ]]; then
    echo -e "\x1B[1;34mThe Persistent Volume Claims have been created.\x1B[0m"
else
    echo -e "\x1B[1;31mFailed\x1B[0m"
fi
#    Check Operator Persistent Volume status every 5 seconds (max 10 minutes) until allocate.
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

# Add the CatalogSource resources to Operator Hub
echo -e "\x1B[1mCreating the Catalog Source...\x1B[0m"
cat ${CATALOG_SOURCE_FILE}
${K8S_CMD} apply -f ${CATALOG_SOURCE_FILE}
sleep 5
echo ""
echo ""
# Create subscription to Business Automation Operator
echo -e "\x1B[1mCreating the Subscription...\n${CP4BA_SUBSCRIPTION_FILE}\n\x1B[0m"
kubectl apply -f -<<EOF
${CP4BA_SUBSCRIPTION_CONTENT}
EOF
echo "Sleeping for 5 minutes"
sleep 300

${K8S_CMD} get pods -n ${CP4BA_PROJECT_NAME} | grep ibm-cp4a-operator
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
    ${K8S_CMD} get pods -n ${CP4BA_PROJECT_NAME} | grep ibm-cp4a-operator
    result=$?
done

# for ((retry=0;retry<=${maxRetry};retry++)); do
# echo "Waiting for CP4BA operator pod initialization"
# isReady=$(${K8S_CMD} get pod -n "${CP4BA_PROJECT_NAME}" --no-headers | grep ibm-cp4a-operator | grep "Running")
# if [[ -z $isReady ]]; then
# if [[ $retry -eq ${maxRetry} ]]; then
#     echo "Timeout Waiting for CP4BA deployment to create"
#     exit 1
# else
#     sleep 5
#     continue
# fi
# else
# echo "CP4BA operator is running $isReady"
# break
# fi
# done


echo -e "\x1B[1mCopying JDBC License Files...\x1B[0m"
podname=$(${K8S_CMD} get pods -n ${CP4BA_PROJECT_NAME} | grep ibm-cp4a-operator | awk '{print $1}')
${K8S_CMD} cp ${CUR_DIR}/files/jdbc ${CP4BA_PROJECT_NAME}/$podname:/opt/ansible/share

# Create Deployment
echo -e "\x1B[1mCreating the Deployment \n${CP4BA_DEPLOYMENT_CONTENT}...\x1B[0m"
${K8S_CMD} apply -n ${CP4BA_PROJECT_NAME} -f -<<EOF
${CP4BA_DEPLOYMENT_CONTENT}
EOF



