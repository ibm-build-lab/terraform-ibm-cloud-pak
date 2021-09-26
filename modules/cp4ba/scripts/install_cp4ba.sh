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

#IBM_CP4BA_CR_FINAL_FILE=${PARENT_DIR}/files/ibm_cp4ba_cr_final.yaml

K8S_CMD=kubectl
OC_CMD=oc

function create_project(){
    echo
    echo "Creating \" ${CP4BA_PROJECT_NAME}\" project ... "
    ${K8S_CMD} create namespace "${CP4BA_PROJECT_NAME}"
    echo
}


# Create the secrets
function create_secrets() {
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
#     echo -e "\x1B[1mCreating secret \"ldap-bind-secret\" in ${CP4BA_PROJECT_NAME} for LDAP...\n\x1B[0m"
#     CREATE_SECRET_RESULT=$(${k8s_CMD} create secret docker-registry ldap-bind-secret -n "${CP4BA_PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${DOCKER_USER_EMAIL}")
#     sleep 5

#     if [[ ${CREATE_SECRET_RESULT} ]]; then
#         echo -e "\033[1;32m \"ldap-bind-secret\" secret has been created\x1B[0m"
#     fi

#     echo -e "\x1B[1mCreating secret \"ibm-db2-secret\" in ${CP4BA_PROJECT_NAME} for DB2...\n\x1B[0m"
# #    CREATE_SECRET_RESULT=$(${k8s_CMD} create secret docker-registry ibm-db2-secret -n "${CP4BA_PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${DOCKER_USER_EMAIL}")
#     CREATE_SECRET_RESULT=$(${k8s_CMD} create secret generic my-ldap-tds-secret --from-literal=ldapUsername="${LDAP_ADMIN_NAME}" --from-literal=ldapPassword="${LDAP_ADMIN_PASSWORD}")
#     sleep 5

#     if [[ ${CREATE_SECRET_RESULT} ]]; then
#         echo -e "\033[1;32m \"ibm-db2-secret\" secret has been created\x1B[0m"
#     fi

#    sleep 5
#    ````
#      apiVersion: v1
#      kind: Secret
#      metadata:
#        name: icp4ba-tls-secret
#      #type: Opaque
#      type: kubernetes.io/tls
#      data:
#        tls.crt: icp4baTlsSecret
#        tls.key: icp4baTlsSecret
#  ````

    echo

kubectl apply -n ${CP4BA_PROJECT_NAME} -f -<<EOF
${SECRETS_CONTENT}
EOF

}

function allocate_operator_pvc(){
    echo -e "\x1B[1mApplying the Persistent Volumes Claim (PVC) for the Cloud Pak operator by using the storage classname: ${SLOW_STORAGE_CLASS_NAME}...\x1B[0m"

    CREATE_PVC_RESULT=$(kubectl -n "${CP4BA_PROJECT_NAME}" apply -f "${OPERATOR_PVC_FILE}")


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
    until (${k8s_CMD} get pvc -n "${CP4BA_PROJECT_NAME}" | grep cp4a-shared-log-pvc | grep "Bound") || [ $ATTEMPTS -eq $TIMEOUT ] ; do
        ATTEMPTS=$((ATTEMPTS + 1))
        echo -e "......"
        sleep 10
        if [ $ATTEMPTS -eq $TIMEOUT ] ; then
            echo -e "\x1B[1;31mFailed to allocate the persistent volumes!\x1B[0m"
            echo -e "\x1B[1;31mRun the following command to check the claim '${K8S_CMD} describe pvc cp4a-shared-log-pvc'\x1B[0m"
            exit 1
        fi
    done
    if [ $ATTEMPTS -lt $TIMEOUT ] ; then
        echo -e "\x1B[1;34m The Persistent Volume Claim is successfully bound Done\x1B[0m"
    fi
    echo

    ATTEMPTS=0
    TIMEOUT=60
    echo -e "\x1B[1mWaiting for the persistent volumes to be ready...\x1B[0m"
    until (${k8s_CMD} get pvc -n "${CP4BA_PROJECT_NAME}" | grep operator-shared-pvc | grep "Bound") || [ $ATTEMPTS -eq $TIMEOUT ] ; do
        ATTEMPTS=$((ATTEMPTS + 1))
        echo -e "......"
        sleep 10
        if [ $ATTEMPTS -eq $TIMEOUT ] ; then
            echo -e "\x1B[1;31mFailed to allocate the persistent volumes!\x1B[0m"
            echo -e "\x1B[1;31mRun the following command to check the claim '${K8S_CMD} describe pvc operator-shared-pvc'\x1B[0m"
            exit 1
        fi
    done
    if [ $ATTEMPTS -lt $TIMEOUT ] ; then
        echo -e "\x1B[1;34m The Persistent Volume Claim is successfully bound Done\x1B[0m"
    fi
    echo
}


# Deploying the Common-Service
function deploy_common_service() {

    # echo "Creating \"common-service\" project ..."
    # ${K8S_CMD} create namespace common-service
    # ${K8S_CMD} namespace common-service

    # if [[ $(oc get og -n "${CP4BA_PROJECT_NAME}" -o=go-template --template='{{len .items}}' ) -gt 0 ]]; then
    #     echo "Found operator group"
    #     oc get og -n "${CP4BA_PROJECT_NAME}"
    # else
    #     echo "Creating Operator Group for Release 3.4..."
    #     ${OC_CMD} apply -f "${CS_APP_REGISTRY_FILE}"
    #     sleep 2
    #     if [ $? -eq 0 ]
    #        then
    #        echo "CP4BA Operator Group Created!"
    #      else
    #        echo "CP4BA Operator Operator Group creation failed"
    #      fi
    # fi
    # echo "Creating Operator Group ... "
    # ${OC_CMD} apply -f "${CS_OPERATOR_GROUP_FILE}"
    # sleep 2

    # echo "Creating Operator Subscription ..."
    # ${OC_CMD} apply -f "${CS_OPERATOR_SUBSCRIPTION_FILE}"
    # sleep 2

    # echo "Creating Operator Request CR ..."
    # ${OC_CMD} apply -f "${CS_OPERATOR_OPERAND_REQUEST_FILE}"
    # sleep 2

    # echo "Creating Operator Request CR ..."
    # ${OC_CMD} apply -f "${OPERATOR_OPERANDREGISTRY_CR_FILE}"
    # sleep 2

    # echo "Creating Operator Request CR ..."
    # ${OC_CMD} apply -f "${OPERATOR_OPERANDREGISTRY_CR_FILE}"
    # sleep 2

    # echo
}


# Create Operator
function create_operator() {
#    INSTALL_OPERATOR_CMD=$("${K8S_CMD}" apply -f "${OPERATOR_FILE}" -n "${CP4BA_PROJECT_NAME}" --validate=false)

#    sleep 5
#    if [[ $INSTALL_OPERATOR_CMD ]]; then
#        echo -e "\x1B[1;34mDone. The \"ibm-cp4a-operator\" has been created.\x1B[0m"
#    else
#        echo -e "\x1B[1;31mFailed\x1B[0m"
#    fi

#     printf "\n"
#    # Check deployment rollout status every 5 seconds (max 10 minutes) until complete.
#    echo -e "\x1B[1mWaiting for the Cloud Pak operator to be ready. This might take a few minutes... \x1B[0m"
#    ATTEMPTS=0
#    ROLLOUT_STATUS_CMD=$("${K8S_CMD}" rollout status deployment/ibm-cp4a-operator -n "${CP4BA_PROJECT_NAME}")

#    sleep 30
#    if ${ROLLOUT_STATUS_CMD} ; then
#        echo -e "\x1B[1;34mDone. \"ibm-cp4a-operator\" is ready for use.\x1B[0m"
#    else
#        echo -e "\x1B[1;31mFailed\x1B[0m"
#    fi
#    printf "\n"

    # Add the CatalogSource resources to Operator Hub
    kubectl apply -f files/catalog_source.yaml

    # Create subscription to Business Automation Operator
    kubectl apply -f files/cp4ba_subscription.yaml
}


function copy_jdbc_driver(){
#     echo
# #    JDBC Driver download link; https://www.ibm.com/support/pages/node/387577
#     # Get pod name
#     echo -e "\x1B[1mCopying the JDBC driver for the operator...\x1B[0m"
#     operator_podname=$(${K8S_CMD} get pod -n "${CP4BA_PROJECT_NAME}" | grep ibm-cp4a-operator | grep Running | awk '{print $1}')

#     # ${K8S_CMD} exec -it ${operator_podname} -- rm -rf /opt/ansible/share/jdbc
#     COPY_JDBC_CMD="${K8S_CMD} cp ${JDBC_DRIVER_DIR} ${operator_podname}:/opt/ansible/share/"

#     echo "Copying jdbc for Db2 from Db2 container to local disk..."
#     ${K8S_CMD} namespace "${DB2_PROJECT_NAME}"
#     rm ./jdbc/db2/*
#     COPY_JDBC_CMD="${OC_CMD} cp ${JDBC_DRIVER_DIR} ${operator_podname}:/opt/ansible/share/"

#     ${OC_CMD} project "${CP4BA_PROJECT_NAME}"

    podname=$(oc get pod | grep ibm-cp4a-operator | awk '{print $1}')
    COPY_JDBC_CMD="${K8S_CMD} cp ./files/jdbc ${CP4BA_PROJECT_NAME}/$podname:/opt/ansible/share
    if ${COPY_JDBC_CMD} ; then
        echo -e "\x1B[1;34mDone. JDBC driver was successfully copied. \x1B[0m"
    else
        echo -e "\x1B[1;31mFailed\x1B[0m"
    fi
    echo
}


# deploy CP4BA
function prepare_deployment_file(){

    # echo
    # echo "Preparing the CR YAML for deployment..."

    # cp "${IBM_CP4BA_CR_FINAL_FILE_TMPL}" "${IBM_CP4BA_CR_FINAL_FILE}"
    # sed -i.bak "s|admin_user|$USER_NAME_EMAIL|g" "${IBM_CP4BA_CR_FINAL_FILE}"
    # sed -i.bak "s|spec.baw_configuration.database.port|$DB2_PORT_NUMBER|g" "${IBM_CP4BA_CR_FINAL_FILE}"
    # sed -i.bak "s|spec.baw_configuration.database.database_name|$DB2_HOST_NAME|g" "${IBM_CP4BA_CR_FINAL_FILE}"
    # sed -i.bak "s|spec.baw_configuration.database.server_name|$DB2_HOST_IP|g" "${IBM_CP4BA_CR_FINAL_FILE}"
    # sed -i.bak "s|sc_fast_file_storage_classname|$SC_FAST_FILE_STORAGE_CLASSNAME|g" "${IBM_CP4BA_CR_FINAL_FILE}"

}


# Apply CP4BA

function cp4ba_deployment() {
    # echo "Creating tls secret key ..."
    # ${OC_CMD} apply -f "${TLS_SECRET_FILE}" -n "${CP4BA_PROJECT_NAME}"

    # echo "Deploying Cloud Pak for Business Automation Capabilities ..."
    # ${OC_CMD} apply -f "${IBM_CP4BA_CR_FINAL_FILE}" -n "${CP4BA_PROJECT_NAME}"

    # ${OC_CMD} project "${CP4BA_PROJECT_NAME}"

    # echo "Creating IBM CP4BA Credentials ..."
    # ${OC_CMD} apply -f "${IBM_CP4BA_CRD_FILE}" -n "${CP4BA_PROJECT_NAME}"
    # sleep 2

    # echo "Creating IBM CP4BA Subscription ... "
    # ${OC_CMD} apply -f "${CP4BA_SUBSCRIPTION_FILE}"


    # if oc get catalogsource -n openshift-marketplace | grep ibm-operator-catalog ; then
    #     echo "Found ibm operator catalog source"
    # else
    #     oc apply -f "${CATALOG_SOURCE_FILE}"
    #     if [ $? -eq 0 ]; then
    #       echo "IBM Operator Catalog source created!"
    #     else
    #       echo "Generic Operator catalog source creation failed"
    #       exit 1
    #     fi
    # fi

    # local maxRetry=20
    # for ((retry=0;retry<=${maxRetry};retry++)); do
    #   echo "Waiting for CP4BA Operator Catalog pod initialization"

    #   isReady=$(${OC_CMD} get pod -n openshift-marketplace --no-headers | grep ibm-operator-catalog | grep "Running")
    #   if [[ -z $isReady ]]; then
    #     if [[ $retry -eq ${maxRetry} ]]; then
    #       echo "Timeout Waiting for  CP4BA Operator Catalog pod to start"
    #       exit 1
    #     else
    #       sleep 5
    #       continue
    #     fi
    #   else
    #     echo "CP4BA Operator Catalog is running $isReady"
    #     break
    #   fi
    # done

kubectl apply -n ${CP4BA_PROJECT_NAME} -f -<<EOF
${CP4BA_DEPLOYMENT_CONTENT}
EOF
    for ((retry=0;retry<=${maxRetry};retry++)); do
      echo "Waiting for CP4BA operator pod initialization"

      isReady=$(${OC_CMD} get pod -n "${CP4BA_PROJECT_NAME}" --no-headers | grep ibm-cp4a-operator | grep "Running")
      if [[ -z $isReady ]]; then
        if [[ $retry -eq ${maxRetry} ]]; then
          echo "Timeout Waiting for CP4BA operator to start"
          exit 1
        else
          sleep 5
          continue
        fi
      else
        echo "CP4BA operator is running $isReady"
        break
      fi
    done

}

# Calling all the functions
create_project
sleep 5
create_secrets
sleep 5
allocate_operator_pvc
sleep 5
copy_jdbc_driver
sleep 5
# prepare_deployment_file
# sleep 5
# create_operator
# sleep 5
cp4ba_deployment
sleep 5

