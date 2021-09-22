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

IBM_CP4BA_CR_FINAL_FILE=${PARENT_DIR}/files/ibm_cp4ba_cr_final.yaml

k8s_CMD=kubectl
OC_CMD=oc

#cp "${OPERATOR_PVC_TEMPLATE}" "${OPERATOR_PVC_FILE_CP}"

# Create project or namespace where cp4ba will be installed
function create_project(){
    echo
#    result=$(${OC_CMD} projects | grep "${PROJECT_NAME}")
#    if [[ -ne $result ]];
#    then
    echo "Creating \" ${CP4BA_PROJECT_NAME}\" project ... "
    ${OC_CMD} new-project "${CP4BA_PROJECT_NAME}"
#    fi
}


# Create the secrets
function create_secrets() {
    echo -e "\x1B[1mCreating secret \"admin.registrykey\" in ${CP4BA_PROJECT_NAME} for CP4BA ...\n\x1B[0m"
    CREATE_SECRET_RESULT=$(${k8s_CMD} create secret docker-registry admin.registrykey -n "${CP4BA_PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${DOCKER_USER_EMAIL}")
    sleep 5

    if [[ ${CREATE_SECRET_RESULT} ]]; then
        echo -e "\033[1;32m \"admin.registrykey\" secret has been created\x1B[0m"
    fi

    echo
    echo -e "\x1B[1mCreating secret \"ibm-entitlement-key\" in ${CP4BA_PROJECT_NAME} for CP4BA ...\n\x1B[0m"
    CREATE_SECRET_RESULT=$(${k8s_CMD} create secret docker-registry ibm-entitlement-key -n "${CP4BA_PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${DOCKER_USER_EMAIL}")
    sleep 5

    if [[ ${CREATE_SECRET_RESULT} ]]; then
        echo -e "\033[1;32m \"ibm-entitlement-key\" secret has been created\x1B[0m"
    fi
    echo
    echo -e "\x1B[1mCreating secret \"ldap-bind-secret\" in ${CP4BA_PROJECT_NAME} for LDAP...\n\x1B[0m"
    CREATE_SECRET_RESULT=$(${k8s_CMD} create secret docker-registry ldap-bind-secret -n "${CP4BA_PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${DOCKER_USER_EMAIL}")
    sleep 5

    if [[ ${CREATE_SECRET_RESULT} ]]; then
        echo -e "\033[1;32m \"ldap-bind-secret\" secret has been created\x1B[0m"
    fi

    echo -e "\x1B[1mCreating secret \"ibm-db2-secret\" in ${CP4BA_PROJECT_NAME} for DB2...\n\x1B[0m"
    CREATE_SECRET_RESULT=$(${k8s_CMD} create secret docker-registry ibm-db2-secret -n "${CP4BA_PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${DOCKER_USER_EMAIL}")
    sleep 5

    if [[ ${CREATE_SECRET_RESULT} ]]; then
        echo -e "\033[1;32m \"ibm-db2-secret\" secret has been created\x1B[0m"
    fi

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
}

function allocate_operator_pvc(){
#    sed -i.tmp "s|REPLACE_PROJECT_NAME|$PROJECT_NAME|g" "${OPERATOR_PVC_FILE_CP}"
#    sed -i.tmp "s|REPLACE_STORAGE_CLASS|$SLOW_STORAGE_CLASS_NAME|g" "${OPERATOR_PVC_FILE_CP}"

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
            echo -e "\x1B[1;31mRun the following command to check the claim ${CLI_CMD} describe pvc operator-shared-pvc'\x1B[0m"
            exit 1
        fi
    done
    if [ $ATTEMPTS -lt $TIMEOUT ] ; then
        echo -e "\x1B[1;34m The Persistent Volume Claims are successfully bound Done\x1B[0m"
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
            echo -e "\x1B[1;31mRun the following command to check the claim ${CLI_CMD} describe pvc operator-shared-pvc'\x1B[0m"
            exit 1
        fi
    done
    if [ $ATTEMPTS -lt $TIMEOUT ] ; then
        echo -e "\x1B[1;34m The Persistent Volume Claims are successfully bound Done\x1B[0m"
    fi
    echo
}


# Adding priviledges to the projects
function add_priviledges() {
    ${OC_CMD} project "${CP4BA_PROJECT_NAME}"
    ${OC_CMD} adm policy add-scc-to-group ibm-anyuid-scc system:authenticated
    ${OC_CMD} adm policy add-scc-to-user ibm-privileged-scc system:authenticated

    echo "Creating ibm-cp4a-operator role ..."
    cmd_result=$(${OC_CMD} apply -f "${ROLE_FILE}" -n "${CP4BA_PROJECT_NAME}")
    if [[ ${cmd_result} ]];
    then
      echo "CP4BA ibm-cp4a-operator role is created."
    fi

    echo "Creating ibm-cp4a-operator rolebinding ..."
    cmd_result=$(${OC_CMD} apply -f "${ROLE_BINDING_FILE}" -n "${CP4BA_PROJECT_NAME}")
    if [[ ${cmd_result} ]];
    then
      echo "CP4BA ibm-cp4a-operator rolebinding is created."
    fi

    echo "Creating ibm-cp4a-operator service account ..."
    cmd_result=$(${OC_CMD} apply -f "${SERVICE_ACCOUNT_FILE}" -n "${CP4BA_PROJECT_NAME}")
    if [[ ${cmd_result} ]];
    then
      echo "CP4BA ibm-cp4a-operator service account is created."
    fi
    echo
}


# Deploying the Common-Service
function deploy_common_service() {
   # I will need this later
#  ````
#  apiVersion: operator.ibm.com/v3
#kind: CommonService
#metadata:
#  name: example-commonservice
#  labels:
#    app.kubernetes.io/instance: ibm-common-service-operator
#    app.kubernetes.io/managed-by: ibm-common-service-operator
#    app.kubernetes.io/name: ibm-common-service-operator
#  namespace: cp4ba
#spec:
#  size: starterset
#  ````
  ############################################################

    echo "Creating \"common-service\" project ..."
    ${OC_CMD} new-project common-service
    ${OC_CMD} project common-service

    if [[ $(oc get og -n "${CP4BA_PROJECT_NAME}" -o=go-template --template='{{len .items}}' ) -gt 0 ]]; then
        echo "Found operator group"
        oc get og -n "${CP4BA_PROJECT_NAME}"
    else
        echo "Creating Operator Group for Release 3.4..."
        ${OC_CMD} apply -f "${CS_APP_REGISTRY_FILE}"
        sleep 2
        if [ $? -eq 0 ]
           then
           echo "CP4BA Operator Group Created!"
         else
           echo "CP4BA Operator Operator Group creation failed"
         fi
    fi
    echo "Creating Operator Group ... "
    ${OC_CMD} apply -f "${CS_OPERATOR_GROUP_FILE}"
    sleep 2

    echo "Creating Operator Subscription ..."
    ${OC_CMD} apply -f "${CS_OPERATOR_SUBSCRIPTION_FILE}"
    sleep 2

    echo "Creating Operator Request CR ..."
    ${OC_CMD} apply -f "${CS_OPERATOR_OPERAND_REQUEST_FILE}"
    sleep 2

    echo "Creating Operator Request CR ..."
    ${OC_CMD} apply -f "${OPERATOR_OPERANDREGISTRY_CR_FILE}"
    sleep 2

    echo "Creating Operator Request CR ..."
    ${OC_CMD} apply -f "${OPERATOR_OPERANDREGISTRY_CR_FILE}"
    sleep 2

    echo
}


# Create Operator
function create_operator() {
   INSTALL_OPERATOR_CMD=$("${k8s_CMD}" apply -f "${OPERATOR_FILE}" -n "${CP4BA_PROJECT_NAME}" --validate=false)

   sleep 5
   if [[ $INSTALL_OPERATOR_CMD ]]; then
       echo -e "\x1B[1;34mDone. The \"ibm-cp4a-operator\" has been created.\x1B[0m"
   else
       echo -e "\x1B[1;31mFailed\x1B[0m"
   fi

    printf "\n"
   # Check deployment rollout status every 5 seconds (max 10 minutes) until complete.
   echo -e "\x1B[1mWaiting for the Cloud Pak operator to be ready. This might take a few minutes... \x1B[0m"
   ATTEMPTS=0
   ROLLOUT_STATUS_CMD=$("${OC_CMD}" rollout status deployment/ibm-cp4a-operator -n "${CP4BA_PROJECT_NAME}")
#   until ${ROLLOUT_STATUS_CMD} || [ "${ATTEMPTS}" -eq 30 ]; do
#       ${ROLLOUT_STATUS_CMD}
#       ATTEMPTS=$(${ATTEMPTS} + 1)
#       sleep 5
#   done
   sleep 30
   if ${ROLLOUT_STATUS_CMD} ; then
       echo -e "\x1B[1;34mDone. \"ibm-cp4a-operator\" is ready for use.\x1B[0m"
   else
       echo -e "\x1B[1;31mFailed\x1B[0m"
   fi
   printf "\n"
}


function copy_jdbc_driver(){
    echo
    # Get pod name
    echo -e "\x1B[1mCopying the JDBC driver for the operator...\x1B[0m"
    operator_podname=$(${OC_CMD} get pod -n "${CP4BA_PROJECT_NAME}" | grep ibm-cp4a-operator | grep Running | awk '{print $1}')

    # ${CLI_CMD} exec -it ${operator_podname} -- rm -rf /opt/ansible/share/jdbc
    COPY_JDBC_CMD="${OC_CMD} cp ${JDBC_DRIVER_DIR} ${operator_podname}:/opt/ansible/share/"

    echo "Copying jdbc for Db2 from Db2 container to local disk..."
    ${OC_CMD} project "${DB2_PROJECT_NAME}"
    rm ./jdbc/db2/*
    ${OC_CMD} cp c-db2ucluster-db2u-0:/opt/ibm/db2/V11.5.0.0/java/db2jcc4.jar ./jdbc/db2/db2jcc4.jar
    ${OC_CMD} cp c-db2ucluster-db2u-0:/opt/ibm/db2/V11.5.0.0/java/db2jcc_license_cu.jar ./jdbc/db2/db2jcc_license_cu.jar
    ${OC_CMD} project "${CP4BA_PROJECT_NAME}"

    if ${COPY_JDBC_CMD} ; then
        echo -e "\x1B[1;34mDone. JDBC driver was successfully copied. \x1B[0m"
    else
        echo -e "\x1B[1;31mFailed\x1B[0m"
    fi
    echo
}


# deploy CP4BA
function prepare_deployment_file(){

    echo
    echo "Preparing the CR YAML for deployment..."

    cp "${IBM_CP4BA_CR_FINAL_FILE_TMPL}" "${IBM_CP4BA_CR_FINAL_FILE}"
    # Adding admin user (email)
    sed -i.bak "s|admin_user|$USER_NAME_EMAIL|g" "${IBM_CP4BA_CR_FINAL_FILE}"
    sed -i.bak "s|spec.baw_configuration.database.port|$DB2_PORT_NUMBER|g" "${IBM_CP4BA_CR_FINAL_FILE}"
    sed -i.bak "s|spec.baw_configuration.database.database_name|$DB2_HOST_NAME|g" "${IBM_CP4BA_CR_FINAL_FILE}"
    sed -i.bak "s|spec.baw_configuration.database.server_name|$DB2_HOST_IP|g" "${IBM_CP4BA_CR_FINAL_FILE}"
    database_name

#    sed -i.bak "s|db2HostName|$db2HostName|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2HostIp|$db2HostIp|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2PortNumber|$db2PortNumber|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2UmsdbName|$db2UmsdbName|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2IcndbName|$db2IcndbName|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2Devos1Name|$db2Devos1Name|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2AeosName|$db2AeosName|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2BawDocsName|$db2BawDocsName|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2BawDosName|$db2BawDosName|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2BawTosName|$db2BawTosName|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2BawDbName|$db2BawDbName|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2AppdbName|$db2AppdbName|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2AedbName|$db2AedbName|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2BasdbName|$db2BasdbName|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2GcddbName|$db2GcddbName|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2CaBasedbName|$db2CaBasedbName|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|db2CaTendbName|$db2CaTendbName|g" "${IBM_CP4BA_CR_FINAL_FILE}"

#    sed -i.bak "s|ic_ldap_admin_user_name|$ldapName|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_selected_ldap_type|$ldapType|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_ldap_server|$ldapServer|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_ldap_port|$ldapPort|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_ldap_base_dn|$ldapBaseDn|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_ldap_user_name_attribute|$ldapUserNameAttribute|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_ldap_user_display_name_attr|$ldapUserDisplayNameAttr|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_ldap_group_base_dn|$ldapGroupBaseDn|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_ldap_group_name_attribute|$ldapGroupNameAttribute|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_ldap_group_display_name_attr|$ldapGroupDisplayNameAttr|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_ldap_group_membership_search_filter|$ldapGroupMembershipSearchFilter|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_ldap_group_member_id_map|$ldapGroupMemberIdMap|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_ad_gc_host|$ldapAdGcHost|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_ad_gc_port|$ldapAdGcPort|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_user_filter|$ldapAdUserFilter|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_group_filter|$ldapAdGroupFilter|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_user_filter|$ldapTdsUserFilter|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|lc_group_filter|$ldapTdsGroupFilter|g" "${IBM_CP4BA_CR_FINAL_FILE}"

#    sed -i.bak "s|cp4baUmsAdminGroup|${CP4BA_UMS_ADMIN_GROUP}|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|sc_deployment_platform|$cp4baDeploymentPlatform|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|cp4baOcpHostname|${CP4BA_OCP_HOSTNAME}|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|sc_slow_file_storage_classname|$SC_SLOW_FILE_STORAGE_CLASSNAME|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|sc_medium_file_storage_classname|$SC_MEDIUM_FILE_STORAGE_CLASSNAME|g" "${IBM_CP4BA_CR_FINAL_FILE}"
    sed -i.bak "s|sc_fast_file_storage_classname|$SC_FAST_FILE_STORAGE_CLASSNAME|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|cp4baReplicaCount|$cp4baReplicaCount|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|cp4baBaiJobParallelism|$cp4baBaiJobParallelism|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|cp4baAdminName|${CP4BA_ADMIN_NAME}|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|cp4baAdminPassword|${CP4BA_ADMIN_PASSWORD}|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|cp4baAdminGroup|${CP4BA_ADMIN_GROUP}|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|cp4baUsersGroup|${CP4BA_USERS_GROUP}|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    CP4BA_ADMIN_NAME = local.cp4ba_admin_name
#      CP4BA_ADMIN_GROUP = local.cp4ba_admin_group
#      CP4BA_USERS_GROUP = local.cp4ba_users_group
#      CP4BA_UMS_ADMIN_NAME = local.cp4ba_ums_admin_name
#      CP4BA_UMS_ADMIN_GROUP = local.cp4ba_ums_admin_group
#      CP4BA_OCP_HOSTNAME = var.cp4ba_ocp_hostname
#      CP4BA_TLS_SECRET_NAME = var.cp4ba_tls_secret_name
#      CP4BA_ADMIN_PASSWORD = var.cp4ba_admin_password
#      CP4BA_UMS_ADMIN_PASSWORD = var.cp4ba_ums_admin_password
#
#    sed -i.bak "s|bawLibertyCustomXml|$bawLibertyCustomXml|g" "${IBM_CP4BA_CR_FINAL_FILE}"
#    sed -i.bak "s|sc_ingress_tls_secret_name|${CP4BA_TLS_SECRET_NAME|g" "${IBM_CP4BA_CR_FINAL_FILE}"
}


# Apply CP4BA

function cp4ba_deployment() {
    echo "Creating tls secret key ..."
    ${CLI_CMD} apply -f "${TLS_SECRET_FILE}" -n "${CP4BA_PROJECT_NAME}"

    echo "Creating the AutomationUIConfig & Cartridge deployment..."
    ${CLI_CMD} apply -f "${AUTOMATION_UI_CONFIG_FILE}" -n "${CP4BA_PROJECT_NAME}"
    ${CLI_CMD} apply -f "${CARTRIDGE_FILE}" -n "${CP4BA_PROJECT_NAME}"
    echo "Done."

    ${CLI_CMD} apply -f "${PARENT_DIR}"/files/t_icp4badeploy.yaml

    echo "Deploying Cloud Pak for Business Automation Capabilities ..."
    ${CLI_CMD} apply -f "${IBM_CP4BA_CR_FINAL_FILE}" -n "${CP4BA_PROJECT_NAME}"

    ${OC_CMD} project "${CP4BA_PROJECT_NAME}"

    echo "Creating IBM CP4BA Credentials ..."
    ${OC_CMD} apply -f "${IBM_CP4BA_CRD_FILE}" -n "${CP4BA_PROJECT_NAME}"
    sleep 2

    echo "Creating IBM CP4BA Subscription ... "
    ${OC_CMD} apply -f "${CP4BA_SUBSCRIPTION_FILE}"


    if oc get catalogsource -n openshift-marketplace | grep ibm-operator-catalog ; then
        echo "Found ibm operator catalog source"
    else
        oc apply -f "${CATALOG_SOURCE_FILE}"
        if [ $? -eq 0 ]; then
          echo "IBM Operator Catalog source created!"
        else
          echo "Generic Operator catalog source creation failed"
          exit 1
        fi
    fi

    local maxRetry=20
    for ((retry=0;retry<=${maxRetry};retry++)); do
      echo "Waiting for CP4BA Operator Catalog pod initialization"

      isReady=$(${OC_CMD} get pod -n openshift-marketplace --no-headers | grep ibm-operator-catalog | grep "Running")
      if [[ -z $isReady ]]; then
        if [[ $retry -eq ${maxRetry} ]]; then
          echo "Timeout Waiting for  CP4BA Operator Catalog pod to start"
          exit 1
        else
          sleep 5
          continue
        fi
      else
        echo "CP4BA Operator Catalog is running $isReady"
        break
      fi
    done

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

#    #  Ts go here
#    oc apply -f "${PARENT_DIR}"/files/t_automation_foundation.yaml
#    oc apply -f "${PARENT_DIR}"/files/t_automation_foundation_core.yaml
#    oc apply -f "${PARENT_DIR}"/files/t_common_services.yaml
#    oc apply -f "${PARENT_DIR}"/files/t_cp4ba_install.yaml

}

# Calling all the functions
create_project
sleep 5
create_secrets
sleep 5
allocate_operator_pvc
sleep 5
deploy_common_service
sleep 5
copy_jdbc_driver
sleep 5
add_priviledges
sleep 5
prepare_deployment_file
sleep 5
create_operator
sleep 5
cp4ba_deployment
sleep 5

