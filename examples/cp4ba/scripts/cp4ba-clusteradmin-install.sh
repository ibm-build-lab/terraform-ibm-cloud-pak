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
# Import common utilities and environment variables
source "${CUR_DIR}"/helper/common.sh
#RUNTIME_MODE=$1

TEMP_FOLDER=${CUR_DIR}/.tmp
INSTALL_BAI=""
CRD_FILE=${PARENT_DIR}/descriptors/ibm_cp4ba_crd.yaml
SA_FILE=${PARENT_DIR}/descriptors/service_account.yaml
CLUSTER_ROLE_FILE=${PARENT_DIR}/descriptors/cluster_role.yaml
CLUSTER_ROLE_BINDING_FILE=${PARENT_DIR}/descriptors/cluster_role_binding.yaml
# CLUSTER_ROLE_BINDING_FILE_TEMP=${TEMP_FOLDER}/.cluster_role_binding.yaml
ROLE_FILE=${PARENT_DIR}/descriptors/role.yaml
ROLE_BINDING_FILE=${PARENT_DIR}/descriptors/role_binding.yaml
BRONZE_STORAGE_CLASS=${PARENT_DIR}/descriptors/cp4ba-bronze-storage-class.yaml
SILVER_STORAGE_CLASS=${PARENT_DIR}/descriptors/cp4ba-silver-storage-class.yaml
GOLD_STORAGE_CLASS=${PARENT_DIR}/descriptors/cp4ba-gold-storage-class.yaml
LOG_FILE=${CUR_DIR}/prepare_install.log

#PLATFORM_VERSION=""
#PROJ_NAME=""
ADMIN_REGISTRY_KEY_SECRET_NAME="admin.registrykey"
REGISTRY_IN_FILE="cp.icr.io"
OPERATOR_FILE=${PARENT_DIR}/descriptors/operator.yaml
OPERATOR_FILE_TMP=$TEMP_FOLDER/.operator_tmp.yaml

OPERATOR_PVC_FILE=${PARENT_DIR}/descriptors/cp4ba-pvc.yaml
OPERATOR_PV_FILE=${PARENT_DIR}/descriptors/cp4ba-pv.yaml

TLS_SECRET_FILE="${PARENT_DIR}"/descriptors/tls_secret_template.yaml
CP4BA_CR_FINAL_FILE="${PARENT_DIR}"/scripts/generated-cr/ibm_cp4ba_cr_final.yaml
#OPERATOR_PVC_FILE_TMP1=${TEMP_FOLDER}/.operator-shared-pvc_tmp1.yaml
#OPERATOR_PVC_FILE_TMP=${TEMP_FOLDER}/.operator-shared-pvc_tmp.yaml
#OPERATOR_PVC_FILE_TMP=${PARENT_DIR}/descriptors/cp4ba-pvc.yaml

#OPERATOR_PVC_FILE_BAK=${TEMP_FOLDER}/.cp4ba-pvc.yaml
JDBC_DRIVER_DIR=${CUR_DIR}/jdbc

COMMON_SERVICES_CRD_DIRECTORY_OCP311=${PARENT_DIR}/descriptors/common-services/scripts
COMMON_SERVICES_CRD_DIRECTORY=${PARENT_DIR}/descriptors/common-services/crds
COMMON_SERVICES_OPERATOR_ROLES=${PARENT_DIR}/descriptors/common-services/roles
COMMON_SERVICES_TEMP_DIR=$TMEP_FOLDER

SCRIPT_MODE=""
RUNTIME_MODE="dev"
####################################################################################
#mkdir -p "$TEMP_FOLDER" >/dev/null 2>&1
#echo "creating temp folder"
# During the development cycle we will need to apply cp4ba_catalogsource.yaml
# catalog_source.yaml is the final deliver yaml.
if [[ $RUNTIME_MODE == "dev" ]];then
    OLM_CATALOG="${PARENT_DIR}"/descriptors/op-olm/cp4ba_catalogsource.yaml
else
    OLM_CATALOG="${PARENT_DIR}"/descriptors/op-olm/catalog_source.yaml
fi
# the source is different for stage of development and final public
if [[ $RUNTIME_MODE == "dev" ]]; then
    online_source="ibm-cp4ba-operator-catalog"
else
    online_source="ibm-operator-catalog"
fi

OLM_OPT_GROUP="${PARENT_DIR}"/descriptors/op-olm/operator_group.yaml
OLM_SUBSCRIPTION="${PARENT_DIR}"/descriptors/op-olm/subscription.yaml

ENTERPRISE_FOUNDATION="${PARENT_DIR}"/descriptors/patterns/ibm_cp4ba_cr_enterprise_foundation.yaml
ENTERPRISE_FOUNDATION_TMP="${TEMP_FOLDER}"/ibm_cp4ba_cr_enterprise_foundation.yaml


OLM_CATALOG_TMP="${TEMP_FOLDER}"/catalog_source.yaml
OLM_OPT_GROUP_TMP="${TEMP_FOLDER}"/.operator_group.yaml
#OLM_SUBSCRIPTION_TMP="${TEMP_FOLDER}"/.subscription.yaml

CLI_CMD=oc
#PLATFORM_SELECTED="ROKS"
PLATFORM_SELECTED="ROKS"
SCRIPT_MODE="OLM"

echo '' > "$LOG_FILE"

# Selecting the platform. ie: ROKS, OCP, Other
function select_platform(){
    printf "\n"
    COLUMNS=12

#    PLATFORM_SELECTED="ROKS"
#    SCRIPT_MODE="OLM"

    create_project
    echo
    select_user
    echo
    if [[ $LOCAL_PUBLIC_REGISTRY_SERVER == "" ]]
    then
        create_secret_entitlement_registry
    fi
    echo
}


function create_secret_entitlement_registry(){
    echo -e "\x1B[1mCreating secret \"${ENTITLED_REGISTRY_KEY_SECRET_NAME}\" in ${PROJECT_NAME} for Entitlement Registry key ...\n\x1B[0m"
    CREATE_SECRET_CMD=$(${CLI_CMD} create secret docker-registry "${ENTITLED_REGISTRY_KEY_SECRET_NAME}" -n "${PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${DOCKER_USER_EMAIL}")
    sleep 30

    if [[ ${CREATE_SECRET_CMD} ]]; then
        echo -e "\033[1;32m \"${ENTITLED_REGISTRY_KEY_SECRET_NAME}\" secret has been created\x1B[0m"
    else
        echo -e "\x1B[1m\"${ENTITLED_REGISTRY_KEY_SECRET_NAME}\" secret creation failed \x1B[0m"
    fi

    echo
    echo -e "\x1B[1mCreating secret \"${ADMIN_REGISTRY_KEY_SECRET_NAME}\" in ${PROJECT_NAME} for Entitlement Registry key ...\n\x1B[0m"
    CREATE_SECRET_CMD=$(${CLI_CMD} create secret docker-registry "${ADMIN_REGISTRY_KEY_SECRET_NAME}" -n "${PROJECT_NAME}" --docker-username="${DOCKER_USERNAME}" --docker-password="${ENTITLED_REGISTRY_KEY}" --docker-server="${DOCKER_SERVER}" --docker-email="${DOCKER_USER_EMAIL}")
    sleep 30

    if [[ ${CREATE_SECRET_CMD} ]]; then
        echo -e "\033[1;32m \"${ADMIN_REGISTRY_KEY_SECRET_NAME}\" secret has been created\x1B[0m"
    else
        echo -e "\x1B[1m \"${ADMIN_REGISTRY_KEY_SECRET_NAME}\" secret creation failed\x1B[0m"
    fi
    echo
}


function validate_cli(){
#     clear
     if [[ $SCRIPT_MODE == "OLM" ]];then
         echo -e "\x1B[1mThis script prepares the OLM for the deployment of some Cloud Pak for Business Automation capabilities \x1B[0m"
     else
         echo -e "\x1B[1mThis script prepares the environment for the deployment of some Cloud Pak for Business Automation capabilities \x1B[0m"
     fi
     echo
     if  [[ $PLATFORM_SELECTED == "OCP" || $PLATFORM_SELECTED == "ROKS" ]]; then
#         if [[ $(which oc) ]] #|| $(which oc &>/dev/null) ]]
         check=$(which oc) # &>/dev/null #--privileged
         checknl=$(which oc &>/dev/null)
         if [[ ${check} || ${checknl} ]]
         then
#             echo "OpenShift CLI is installed."
             echo -e  "\x1B[1;34mOpenShift CLI is installed.\x1B[0m"
         else :
#         which oc &>/dev/null
#         [[ $? -ne 0 ]] && \
             echo "Unable to locate an OpenShift CLI. You must install it to run this script." && \
             exit 1
         fi

     fi
     if  [[ $PLATFORM_SELECTED == "other" ]]; then
         which kubectl &>/dev/null
         [[ $? -ne 0 ]] && \
             echo "Unable to locate Kubernetes CLI, please install it first." && \
             exit 1
     fi
 }


############## Assigning Deployment Type #################
function select_deployment_type(){
   COLUMNS=12

   if [[ $DEPLOYMENT_TYPE == 1 ]]
   then
       DEPLOYMENT_TYPE="Demo"
   elif [[ $DEPLOYMENT_TYPE == 2 ]]
   then
       DEPLOYMENT_TYPE="Enterprise"
   fi
}


function create_project() {

   if [[ "$PLATFORM_SELECTED" == "OCP" || "$PLATFORM_SELECTED" == "ROKS" ]]; then
       isProjExists=$(${CLI_CMD} get project "$PROJECT_NAME" --ignore-not-found | wc -l)  >/dev/null 2>&1

       if [ "$isProjExists" -ne 2 ] ; then
           create_ns=$("${CLI_CMD}" new-project "${PROJECT_NAME}" "${LOG_FILE}")
           echo -e "\033[1;32m Creating \"${PROJECT_NAME}\" project ... \x1B[0m"
           if [[ ${create_ns} ]]; then
             echo -e "\033[1;32m \"${PROJECT_NAME}\" project is created ... \x1B[0m"
           fi
           returnValue=$?
           if [ "$returnValue" == 1 ]; then
               echo -e "\x1B[1mInvalid project name, please enter a valid name...\x1B[0m"
               PROJECT_NAME=""
           else
               echo -e "\033[1;32m Using project ${PROJECT_NAME}... \x1B[0m"
           fi
       else
           echo -e "\033[1;32mProject \"${PROJECT_NAME}\" already exists! Continue...\x1B[0m"
       fi
   elif [[ "$PLATFORM_SELECTED" == "other" ]]
   then
       isProjExists=$(kubectl get namespace PROJECT_NAME --ignore-not-found | wc -l)  >/dev/null 2>&1

       if [ "$isProjExists" -ne 2 ] ; then
           kubectl create namespace ${PROJECT_NAME} >> "${LOG_FILE}"
           returnValue=$?
           if [ "$returnValue" == 1 ]; then
                echo -e "\x1B[1m Invalid namespace, please enter a valid name...\x1B[0m"
               PROJECT_NAME=""
           else
               echo -e "\033[1;32m Using namespace \"${PROJECT_NAME}\"...\x1B[0m"
           fi
       else
           echo -e "\033[1;32m Name space \"${PROJECT_NAME}\" already exists! Continue...\x1B[0m"
       fi
   fi
   echo
}


function apply_no_root_squash() {
   echo
   echo
   if [[ $PLATFORM_SELECTED == "ROKS" ]] && [[ "$DEPLOYMENT_TYPE" == "demo" ]] && [[ "$DEPLOYMENT_TYPE" == "Demo" ]];
   then
      echo ""
      echo "Applying no_root_squash for demo DB2 deployment on ROKS using CLI"
      "${CLI_CMD}" get no -l node-role.kubernetes.io/worker --no-headers -o name | xargs -I {} --  "${CLI_CMD}" debug {} -- chroot /host sh -c 'grep "^Domain = slnfsv4.coms" /etc/idmapd.conf || ( sed -i "s/.*Domain =.*/Domain = slnfsv4.com/g" /etc/idmapd.conf; nfsidmap -c; rpc.idmapd )' >> "${LOG_FILE}"
   fi
}


function clean_up(){
    rm -rf "${TEMP_FOLDER}" >/dev/null 2>&1
}



function display_installationprompt(){

    echo "IBM Common Services with Metering & Licensing Components will be installed"

    NAMESPACE_ODLM="common-service"
    "${CLI_CMD}" project $NAMESPACE_ODLM >/dev/null 2>&1 || "${CLI_CMD}" new-project "$NAMESPACE_ODLM" >/dev/null 2>&1
}





################### Selecting the user ######################
function select_user(){
     echo
     user_result=$(${CLI_CMD} get user 2>&1) #$(oc get user 2>&1)   # $(${CLI_CMD} get user 2>&1)
     user_substring="No resources found"
     if [[ $user_result == "$user_substring" ]];
     then
  #       clear
         echo -e "\x1B[1;31mAt least one user must be available in order to proceed.\n\x1B[0m"
         echo -e "\x1B[1;31mPlease refer to the README for the requirements and instructions.  The script will now exit.!\n\x1B[0m"
         exit 1
     fi
     echo
     userlist=$(${CLI_CMD} get user|awk '{if(NR>1){if(NR==2){ arr=$1; }else{ arr=arr" "$1; }} } END{ print arr }')   #$(oc get user|awk '{if(NR>1){if(NR==2){ arr=$1; }else{ arr=arr" "$1; }} } END{ print arr }') #
     COLUMNS=12
     echo -e "\x1B[1mHere are the existing users on this cluster: ${userlist}\x1B[0m"
     options="$userlist"
#     usernum=${#options[*]}

     for opt in "${options[@]}"
     do
#       if [[ -n "$opt" && "${options[@]}" && *"$USER_NAME_EMAIL"* =~ $opt ]]; then
#        if [[ -n "$opt" && "*$USER_NAME_EMAIL*" =~ $opt ]]; then
        if [[ $opt == *"$USER_NAME_EMAIL"* ]]; then
            echo "Using ${USER_NAME_EMAIL}"
#           user_name="$USER_NAME_EMAIL"
           break
         else
           echo "invalid option $REPLY"
         fi;
     done
}



function check_user_exist() {
   echo
   echo

   "${CLI_CMD}" get user | grep "${USER_NAME_EMAIL}" >/dev/null 2>&1
   returnValue=$?
   if [ "$returnValue" == 1 ] ; then
       echo -e "\x1B[1mUser \"${USER_NAME_EMAIL}\" NOT exists! Please enter an existing username in your cluster...\x1B[0m"
       USER_NAME_EMAIL=""
   else
       echo -e "\x1B[1mUser \"${USER_NAME_EMAIL}\" exists! Continue...\x1B[0m"
   fi
}


function bind_scc() {
    echo
    echo -ne Binding the 'privileged' role to the 'default' service account...
    dba_scc=$("${CLI_CMD}" get scc privileged | awk '{print $1}' )
    if [ -n "$dba_scc" ]; then
        ${CLI_CMD} adm policy add-scc-to-user privileged -z default  >>  "${LOG_FILE}"
    else
        echo "The 'privileged' security context constraint (SCC) does not exist in the cluster. Make sure that you update your environment to include this SCC."
        exit 1
    fi
    echo "Done"
}


function prepare_install() {
   echo

#     if [[ "$PLATFORM_SELECTED" == "OCP" || "$PLATFORM_SELECTED" == "ROKS" ]]; then
   "${CLI_CMD}" project "${PROJECT_NAME}" >> "${LOG_FILE}"
#     fi
    sed -e "s/<NAMESPACE>/${PROJECT_NAME}/g" "${CLUSTER_ROLE_BINDING_FILE}" > "${CLUSTER_ROLE_BINDING_FILE_TEMP}"
   echo
   echo -ne "Creating the custom resource definition (CRD) and a service account that has the permissions to manage the resources..."
   ${CLI_CMD} apply -f "${CRD_FILE}" -n "${PROJECT_NAME}" --validate=false >/dev/null 2>&1
   echo " Done!"
#   if [[ "$DEPLOYMENT_TYPE" == "demo" ]];then
#      ${CLI_CMD} apply -f "${CLUSTER_ROLE_FILE} "--validate=false >> "${LOG_FILE}"
#      ${CLI_CMD} apply -f "${CLUSTER_ROLE_BINDING_FILE}" --validate=false >> "${LOG_FILE}"
#   fi
   echo "Creating storage-classes ..."
   print "\n"
#   ${CLI_CMD} apply -f "${SA_FILE}" -n "${PROJECT_NAME}" --validate=false >> "${LOG_FILE}"
   oc apply -f "${SA_FILE}" -n "${PROJECT_NAME}" --validate=false >> "${LOG_FILE}"

   echo "Creating the cluster role ..."
   print "\n"
#   ${CLI_CMD} apply -f "${ROLE_FILE}" -n "${PROJECT_NAME}" --validate=false >> "${LOG_FILE}"
   oc apply -f "${ROLE_FILE}" -n "${PROJECT_NAME}" --validate=false >> "${LOG_FILE}"

   echo -n "Creating ibm-cp4ba-operator role ..."
   while true ; do
       result=$(${CLI_CMD} get role -n $PROJECT_NAME | grep ibm-cp4ba-operator)
       if [[ "$result" == "" ]] ; then
           sleep 5
           echo -n "..."
       else
           echo " Done!"
           break
       fi
   done

   echo -n "Creating ibm-cp4ba-operator role binding ..."
   ${CLI_CMD} apply -f "${ROLE_BINDING_FILE}" -n ${PROJECT_NAME} --validate=false >> "${LOG_FILE}"
   echo "Done!"

   if [[ "$PLATFORM_SELECTED" == "OCP" || "$PLATFORM_SELECTED" == "ROKS" ]]; then
       echo
       echo -ne Adding the user ${USER_NAME_EMAIL} to the ibm-cp4ba-operator role...
       printf "\n"
       ${CLI_CMD} project "${PROJECT_NAME}" >> "${LOG_FILE}"
       ${CLI_CMD} adm policy add-role-to-user edit ${USER_NAME_EMAIL} >> "${LOG_FILE}"
       ${CLI_CMD} adm policy add-role-to-user registry-editor ${USER_NAME_EMAIL} >> "${LOG_FILE}"
       ${CLI_CMD} adm policy add-role-to-user ibm-cp4ba-operator "${USER_NAME_EMAIL}" >/dev/null 2>&1
       ${CLI_CMD} adm policy add-role-to-user ibm-cp4ba-operator "${USER_NAME_EMAIL}" >> "${LOG_FILE}"
       if [[ "$DEPLOYMENT_TYPE" == "demo" ]];then
           "${CLI_CMD}" adm policy add-cluster-role-to-user ibm-cp4ba-operator "${USER_NAME_EMAIL}" >> "${LOG_FILE}"
       fi
       echo "Done!"
   fi
   echo
   echo -ne Label the default namespace to allow network policies to open traffic to the ingress controller using a namespaceSelector...
   "${CLI_CMD}" label --overwrite namespace default 'network.openshift.io/policy-group=ingress'
   echo "Done!"
}


function apply_cp4ba_operator(){

   echo

   "${COPY_CMD}" -rf "${OPERATOR_FILE}" "${OPERATOR_FILE_TMP}"

   printf "\n"
   if [[ ("$SCRIPT_MODE" != "review") && ("$SCRIPT_MODE" != "OLM") ]]; then
       echo -e "\x1B[1mInstalling the Cloud Pak for Business Automation operator...\x1B[0m"
      exit 0
   fi
   SED_COMMAND=sed
   # set db2_license
   "${SED_COMMAND}" '/baw_license/{n;s/value:.*/value: accept/;}' "${OPERATOR_FILE_TMP}"
   # Set operator image pull secret
   "${SED_COMMAND}" "s|admin.registrykey|$ADMIN_REGISTRY_KEY_SECRET_NAME|g" "${OPERATOR_FILE_TMP}"
   # Set operator image registry
   new_operator="$REGISTRY_IN_FILE\/cp\/cp4ba"

   if [ "$USE_ENTITLEMENT" = "yes" ] ; then
       "${SED_COMMAND}" "s/$REGISTRY_IN_FILE/$DOCKER_SERVER/g" "${OPERATOR_FILE_TMP}"
   else
       "${SED_COMMAND}" "s/$new_operator/$CONVERT_LOCAL_REGISTRY_SERVER/g" "${OPERATOR_FILE_TMP}"
   fi

   INSTALL_OPERATOR_CMD=$("${CLI_CMD}" apply -f "${OPERATOR_FILE}" -n "$PROJECT_NAME") # "${OPERATOR_FILE_TMP}"
   sleep 5
   if [[ $INSTALL_OPERATOR_CMD ]]; then
       echo -e "\x1B[1;34mDone\x1B[0m"
   else
       echo -e "\x1B[1;31mFailed\x1B[0m"
   fi

    ${COPY_CMD} -rf "${OPERATOR_FILE_TMP}" "${OPERATOR_FILE_BAK}"
   printf "\n"
   # Check deployment rollout status every 5 seconds (max 10 minutes) until complete.
   echo -e "\x1B[1mWaiting for the Cloud Pak operator to be ready. This might take a few minutes... \x1B[0m"
   ATTEMPTS=0
   ROLLOUT_STATUS_CMD=$("${CLI_CMD}" rollout status deployment/ibm-cp4ba-operator -n "$PROJECT_NAME")
   until $ROLLOUT_STATUS_CMD || [ $ATTEMPTS -eq 120 ]; do
       $ROLLOUT_STATUS_CMD
       ATTEMPTS=$((ATTEMPTS + 1))
       sleep 5
   done
   if $ROLLOUT_STATUS_CMD ; then
       echo -e "\x1B[1;34mDone\x1B[0m"
   else
       echo -e "\x1B[1;31mFailed\x1B[0m"
   fi
   printf "\n"
}


function copy_jdbc_driver(){
    echo
    # Get pod name
    echo -e "\x1B[1mCopying the JDBC driver for the operator...\x1B[0m"
    operator_podname=$(${CLI_CMD} get pod -n $PROJECT_NAME | grep ibm-cp4ba-operator | grep Running | awk '{print $1}')

    # ${CLI_CMD} exec -it ${operator_podname} -- rm -rf /opt/ansible/share/jdbc
    COPY_JDBC_CMD="${CLI_CMD} cp ${JDBC_DRIVER_DIR} ${operator_podname}:/opt/ansible/share/"

    if $COPY_JDBC_CMD ; then
        echo -e "\x1B[1;34mDone\x1B[0m"
    else
        echo -e "\x1B[1;31mFailed\x1B[0m"
    fi
    echo
}


function prepare_olm_install() {
   echo
   echo
   local maxRetry=20

   if (${CLI_CMD} get catalogsource -n openshift-marketplace | grep $online_source); then
       echo "Found existing ibm operator catalog source, updating it"
       "${CLI_CMD}" apply -f "$OLM_CATALOG"
       if [ $? -eq 0 ]; then
         echo "IBM Operator Catalog source updated!"
       else
         echo "Generic Operator catalog source update failed"
         exit 1
       fi
   else
        ${CLI_CMD} apply -f "$OLM_CATALOG"
        if [ $? -eq 0 ]; then
          echo "IBM Operator Catalog source created!"
        else
          echo "Generic Operator catalog source creation failed"
          exit 1
        fi
   fi

   for ((retry=0;retry<=${maxRetry};retry++)); do
      echo "Waiting for CP4BA Operator Catalog pod initialization"

      isReady=$(${CLI_CMD} get pod -n openshift-marketplace --no-headers | grep $online_source | grep "Running")
      if [[ -z $isReady ]]; then
        if [[ $retry -eq ${maxRetry} ]]; then
          echo "Timeout Waiting for  CP4BA Operator Catalog pod to start"
          exit 1
        else
          sleep 15
          continue
        fi
      else
        echo "CP4BA Operator Catalog is running $isReady"
        break
      fi
   done


   if [[ $(${CLI_CMD} get og -n "${PROJECT_NAME}" -o=go-template --template='{{len .items}}' ) -gt 0 ]]; then
        echo "Found operator group"
        ${CLI_CMD} get og -n "${PROJECT_NAME}"
    else
      sed "s/REPLACE_NAMESPACE/$PROJECT_NAME/g" "${OLM_OPT_GROUP}" > "${OLM_OPT_GROUP_TMP}"
      ${CLI_CMD} apply -f "${OLM_OPT_GROUP}"
      if [ $? -eq 0 ]
         then
         echo "CP4BA Operator Group Created!"
       else
         echo "CP4BA Operator Operator Group creation failed"
       fi
    fi

    sed "s/REPLACE_NAMESPACE/$project_name/g" "${OLM_SUBSCRIPTION}" > "${OLM_SUBSCRIPTION_TMP}"
    ${YQ_CMD} w -i "${OLM_SUBSCRIPTION}" spec.source "$online_source"
    ${CLI_CMD} apply -f "${OLM_SUBSCRIPTION}"
    # sed <"${OLM_SUBSCRIPTION}" "s|REPLACE_NAMESPACE|${project_name}|g; s|REPLACE_CHANNEL_NAME|stable|g" | oc apply -f -
    if [ $? -eq 0 ]
        then
        echo "CP4BA Operator Subscription Created!"
    else
        echo "CP4BA Operator Subscription creation failed"
        exit 1
    fi

   for ((retry=0;retry<=${maxRetry};retry++)); do
     echo "Waiting for CP4BA Operator Catalog pod initialization"

     isReady=$(${CLI_CMD} get pod -n openshift-marketplace --no-headers | grep $online_source | grep "Running")
     if [[ -z $isReady ]]; then
       if [[ $retry -eq ${maxRetry} ]]; then
         echo "Timeout Waiting for  CP4BA Operator Catalog pod to start"
         exit 1
       else
         sleep 15
         continue
       fi
     else
        echo "CP4BA Operator Catalog is running $isReady"
        if [[ "$DEPLOYMENT_TYPE" == "Enterprise" && "$RUNTIME_MODE" == "dev" ]]; then
            copy_jdbc_driver
        fi
        break
     fi
   done

   echo
   echo -ne Adding the user ${USER_NAME_EMAIL} to the ibm-cp4ba-operator role...
   printf "\n"
   role_name_olm=$(${CLI_CMD} get role -n "$PROJECT_NAME" --no-headers | grep ibm-cp4ba-operator.v|awk '{print $1}')
   if [[ -z $role_name_olm ]]; then
       echo "No role found for CP4BA operator"
       exit 1
   else
       ${CLI_CMD} project "${PROJECT_NAME}" >> "${LOG_FILE}"
       ${CLI_CMD} adm policy add-role-to-user edit "${USER_NAME_EMAIL}" >> "${LOG_FILE}"
       ${CLI_CMD} adm policy add-role-to-user registry-editor "${USER_NAME_EMAIL}" >> "${LOG_FILE}"
       ${CLI_CMD} adm policy add-role-to-user "$role_name_olm" "${USER_NAME_EMAIL}" >/dev/null 2>&1
       ${CLI_CMD} adm policy add-role-to-user "$role_name_olm" "${USER_NAME_EMAIL}" >> "${LOG_FILE}"
       if [[ "$DEPLOYMENT_TYPE" == "demo" ]];then
           cluster_role_name_olm=$(${CLI_CMD} get clusterrole|grep ibm-cp4ba-operator.v|sort -t"t" -k1r|awk 'NR==1{print $1}')
           if [[ -z $cluster_role_name_olm ]]; then
               echo "No cluster role found for CP4BA operator 2"
               exit 1
           else
               ${CLI_CMD} adm policy add-cluster-role-to-user "$cluster_role_name_olm" "${USER_NAME_EMAIL}" >> "${LOG_FILE}"
           fi
       fi
       echo -e "Done!"
   fi
       echo
    echo -ne Label the default namespace to allow network policies to open traffic to the ingress controller using a namespaceSelector...
    ${CLI_CMD} label --overwrite namespace default 'network.openshift.io/policy-group=ingress'
    echo "Done"
}

function check_existing_sc(){
   echo
   echo
#  Check existing storage class
   sc_result=$(${CLI_CMD} get sc 2>&1)

   sc_substring="No resources found"
   if [[ $sc_result == *"$sc_substring"* ]];
   then
#       clear
       echo -e "\x1B[1;31mAt least one dynamic storage class must be available in order to proceed.\n\x1B[0m"
       echo -e "\x1B[1;31mPlease refer to the README for the requirements and instructions.  The script will now exit!.\n\x1B[0m"
       exit 1
   fi
}

function validate_docker_podman_cli(){
    echo
    echo "Checking docker podman"
#   if [[ "$machine" == "Mac" || $PLATFORM_SELECTED == "other" ]];then
#    if [[ $? -ne 0 ]]
    check=$(which docker) # &>/dev/null #--privileged
    checknl=$(which docker &>/dev/null)

    if [[ ${check} || ${checknl} ]]
    then
      echo -e  "\x1B[1;34mDocker is installed and located.\x1B[0m"
    else
      echo -e  "\x1B[1;31m Unable to locate docker, please install it first.\x1B[0m"
      exit 1
    fi

    check=$(which podman) # &>/dev/null #--privileged
    checknl=$(which podman &>/dev/null)
#    which podman
#    if [[ $? -ne 0 ]]
    if [[ ${check} || ${checknl} ]]
    then
        echo -e  "\x1B[1;34mPodman is installed and located.\x1B[0m"
    else
        echo -e  "\x1B[1;31mUnable to locate podman, please install it first.\x1B[0m"
        exit 1
    fi
#    which podman # &>/dev/null
#    [[ $? -ne 0 ]] && echo -e "\x1B[1;31mUnable to locate podman, please install it first.\x1B[0m" && exit 1
#   fi
    echo
}


function get_entitlement_registry(){
   echo
   if [[ "$machine" == "Mac" ]]; then
        cli_command="docker"
   else
        cli_command="podman"
   fi

   if $cli_command login -u "${DOCKER_USERNAME}" -p "${ENTITLED_REGISTRY_KEY}" "${DOCKER_SERVER}";
   then
        printf 'Entitlement Registry key is valid.\n'
        entitlement_verify_passed="passed"
   else
        printf '\x1B[1;31mThe Entitlement Registry key failed.\n\x1B[0m'
        printf '\x1B[1mEnter a valid Entitlement Registry key.\n\x1B[0m'
        printf "\x1B[1;31mOr follow the instructions on how to get your Entitlement Key: \n\x1B[0m"
        printf "\x1B[1;31mhttps://www.ibm.com/support/knowledgecenter/en/SSYHZ8_21.0.x/com.ibm.dba.install/op_topics/tsk_images_enterp_entitled.html\n\x1B[0m"
   fi
   echo
}


######################## Getting the storage classes #######################
function get_storage_class_name(){

    echo

    check_storage_class

    STORAGE_CLASS_NAME=${STORAGE_CLASSNAME}
    SLOW_STORAGE_CLASS_NAME=${SC_SLOW_FILE_STORAGE_CLASSNAME}
    MEDIUM_STORAGE_CLASS_NAME=${SC_MEDIUM_FILE_STORAGE_CLASSNAME}
    FAST_STORAGE_CLASS_NAME=${SC_FAST_FILE_STORAGE_CLASSNAME}
}


#function create_secret_entitlement_registry(){
#    # Create docker-registry secret for Entitlement Registry Key in target project
#    printf "\x1B[1mCreating docker-registry secret for Entitlement Registry key in project $PROJECT_NAME ...\n\x1B[0m"
#
#    ${CLI_CMD} delete secret "$ADMIN_REGISTRY_KEY_SECRET_NAME" -n "${PROJECT_NAME}" >/dev/null 2>&1
#    CREATE_SECRET_CMD="${CLI_CMD} create secret docker-registry $ADMIN_REGISTRY_KEY_SECRET_NAME --docker-server=$DOCKER_REG_SERVER --docker-username=$DOCKER_REG_USER --docker-password=$DOCKER_REG_KEY --docker-email=ecmtest@ibm.com -n $project_name"
#    if $CREATE_SECRET_CMD ; then
#        echo -e "\x1B[1mDone\x1B[0m"
#    else
#        echo -e "\x1B[1mFailed\x1B[0m"
#    fi
#}

function allocate_operator_pvc_olm_or_cncf(){
    echo -e "\x1B[1mApplying the Persistent Volumes Claim (PVC) for the Cloud Pak operator by using the storage classname: ${SLOW_STORAGE_CLASS_NAME}...\x1B[0m"
    CREATE_PVC_CMD=$("${CLI_CMD}" apply -f "${OPERATOR_PVC_FILE}" -n "$PROJECT_NAME")   # "${CLI_CMD} apply -f ${OPERATOR_PVC_FILE_TMP} -n $PROJECT_NAME"

    if [[ $CREATE_PVC_CMD ]]; then
        echo -e "\x1B[1;34mThe Persistent Volume Claims have been created.\x1B[0m"
    else
        echo -e "\x1B[1;31mFailed\x1B[0m"
    fi
    #    Check Operator Persistent Volume status every 5 seconds (max 10 minutes) until allocate.
    ATTEMPTS=0
    TIMEOUT=60
    printf "\n"
    echo -e "\x1B[1mWaiting for the persistent volumes to be ready...\x1B[0m"
    until ${CLI_CMD} get pvc -n $PROJECT_NAME | grep cp4ba-shared-log-pvc | grep -q -m 1 "Bound" || [ $ATTEMPTS -eq $TIMEOUT ]; do
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

function display_storage_classes() {
#    echo "Storage classes are needed to run the deployment script. For the \"Demo\" deployment scenario, you may use one (1) storage class.  For an \"Enterprise\" deployment, the deployment script will ask for three (3) storage classes to meet the "slow", "medium", and "fast" storage for the configuration of CP4BA components.  If you don't have three (3) storage classes, you can use the same one for "slow", "medium", or fast.  Note that you can get the existing storage class(es) in the environment by running the following command: oc get storageclass. Take note of the storage classes that you want to use for deployment. "
    echo
    echo "Storage classes list:"
    echo
    ${CLI_CMD} get storageclass
    echo
}


function display_node_name() {
    echo
    if  [[ $PLATFORM_VERSION == "3.11" ]];
    then
        echo "Below is the host name of the Infrastructure Node for the environment, which is required as an input during the execution of the deployment script for the creation of routes in OCP.  You can also get the host name by running the following command: ${CLI_CMD} get nodes --selector node-role.kubernetes.io/infra=true -o custom-columns=":metadata.name". Take note of the host name. "
	      ${CLI_CMD} get nodes --selector node-role.kubernetes.io/infra=true -o custom-columns=":metadata.name"
    elif  [[ $PLATFORM_VERSION == "4.4OrLater" ]];
    then
        echo "Below is the route host name for the environment, which is required as an input during the execution of the deployment script for the creation of routes in OCP. You can also get the host name by running the following command: oc get route console -n openshift-console -o yaml|grep routerCanonicalHostname. Take note of the host name. "
        ${CLI_CMD} get route console -n openshift-console -o yaml | grep routerCanonicalHostname | head -1 | cut -d ' ' -f 6
    fi
    echo
}


function create_scc() {
    ${CLI_CMD} create serviceaccount ibm-pfs-es-service-account
    ${CLI_CMD} create -f ibm-pfs-privileged-scc.yaml
    ${CLI_CMD} adm policy add-scc-to-user ibm-pfs-privileged-scc -z ibm-pfs-es-service-account
}


function create_storage_classes_roks() {
    echo
    echo -ne "\x1B[1mCreate storage classes for deployment... \x1B[0m"
    ${CLI_CMD} apply -f "${BRONZE_STORAGE_CLASS}" --validate=false >/dev/null 2>&1
    ${CLI_CMD} apply -f "${SILVER_STORAGE_CLASS}" --validate=false >/dev/null 2>&1
    ${CLI_CMD} apply -f "${GOLD_STORAGE_CLASS}" --validate=false >/dev/null 2>&1
    echo -e "\x1B[1;34mDone creating the storage classes. \x1B[0m"
    echo
}


function check_storage_class() {
    echo
    if [[ $PLATFORM_SELECTED == "ROKS" ]];
    then
       create_storage_classes_roks
    fi
    echo
    display_storage_classes
    echo
}


function display_storage_classes_roks() {
    sc_bronze_name=cp4ba-file-retain-bronze-gid
    sc_silver_name=cp4ba-file-retain-silver-gid
    sc_gold_name=cp4ba-file-retain-gold-gid
    echo -e "\x1B[1;31m    $sc_bronze_name \x1B[0m"
    echo -e "\x1B[1;31m    $sc_silver_name \x1B[0m"
    echo -e "\x1B[1;31m    $sc_gold_name \x1B[0m"
    echo
}

function check_platform_version(){
    currentver=$(${CLI_CMD}  get nodes | awk 'NR==2{print $5}')
    requiredver="v1.17.1"
    if [ "$(printf '%s\n' "$requiredver" "$currentver" | sort -V | head -n1)" = "$requiredver" ]; then
        PLATFORM_VERSION="4.4OrLater"
        OCP_VERSION="4.4OrLater"
    else
        # PLATFORM_VERSION="3.11"
        PLATFORM_VERSION="4.4OrLater"
        echo -e "\x1B[1;31mIMPORTANT: Only support OCp4.4 or Later, exit...\n\x1B[0m"
#        read -rsn1 -p"Press any key to continue";echo
#        exit 1
    fi
    # OpenShift 4.0-4.2, install Common Services 3.3
    # OpenShift >= 4.3, install Common Services 3.4
    cs_install_ver="v1.17.1"
    if [ "$(printf '%s\n' "$cs_install_ver" "$currentver" | sort -V | head -n1)" = "$cs_install_ver" ]; then
        CS_VERSION="3.4"
    else
        CS_VERSION="3.3"
    fi
    echo
}

function prepare_common_service(){

    echo
    echo
    echo -e "\x1B[1mThe script is preparing the custom resources (CR) files for OCP Common Services.  You are required to update (fill out) the necessary values in the CRs and deploy Common Services prior to the deployment. \x1B[0m"
    echo -e "The prepared CRs for IBM common Services are located here: %s""${COMMON_SERVICES_CRD_DIRECTORY}"
    echo -e "After making changes to the CRs, execute the 'deploy_CS.sh' script to install Common Services."
    echo -e "Done"
}

function install_common_service_34(){
    echo
    echo
    if [ "$INSTALL_BAI" == "Yes" ] ; then
    echo -e "Preparing full Common Services Release 3.4 CR for BAI Deployment.."
        func_operand_request_cr_bai_34

    else
    echo -e "Preparing minimal Common Services Release 3.4 CR for non-BAI Deployment.."
        func_operand_request_cr_nonbai_34
    fi

     ## TODO: start to install common service
    echo -e "\x1B[1mThe installation of Common Services has started.\x1B[0m"
    #sh ./deploy_CS3.4.sh
    nohup "${PARENT_DIR}"/scripts/deploy_CS3.4.sh  &
    echo -e "Done"
}

function install_common_service_33(){
    echo
    echo
    func_operand_request_cr_nonbai_33
    echo -e "\x1B[1mThe installation of Common Services Release 3.3 for OCP 4.2+ has started.\x1B[0m"
    sh "${PARENT_DIR}"/scripts/deploy_CS3.3.sh

    echo -e "Done"
}

function func_operand_request_cr_bai_34()
{
   echo
   echo
   echo "Creating Common Services V3.4 Operand Request for BAI deployments on OCP 4.3+ ..\x1B[0m" >> "${LOG_FILE}"
   operator_source_path=${PARENT_DIR}/descriptors/common-services/crds/operator_operandrequest_cr.yaml
 cat << ENDF > "${operator_source_path}"
apiVersion: operator.ibm.com/v1alpha1
kind: OperandRequest
metadata:
  name: common-service
  namespace: ibm-common-services
spec:
  requests:
  - registry: common-service
    registryNamespace: ibm-common-services
    operands:
        - name: ibm-licensing-operator
        - name: ibm-iam-operator
        - name: ibm-monitoring-exporters-operator
        - name: ibm-monitoring-prometheusext-operator
        - name: ibm-monitoring-grafana-operator
        - name: ibm-metering-operator
        - name: ibm-management-ingress-operator
        - name: ibm-commonui-operator
ENDF
}


function func_operand_request_cr_nonbai_34()
{
   echo
   echo
   echo "Creating Common-Services V3.4 Operand Request for non-BAI deployments on OCP 4.3 ..\x1B[0m" >> "${LOG_FILE}"
   operator_source_path=${PARENT_DIR}/descriptors/common-services/crds/operator_operandrequest_cr.yaml
 cat << ENDF > "${operator_source_path}"
apiVersion: operator.ibm.com/v1alpha1
kind: OperandRequest
metadata:
  name: common-service
  namespace: ibm-common-services
spec:
  requests:
  - registry: common-service
    registryNamespace: ibm-common-services
    operands:
        - name: ibm-licensing-operator
        - name: ibm-metering-operator
        - name: ibm-commonui-operator
        - name: ibm-management-ingress-operator
        - name: ibm-iam-operator
        - name: ibm-platform-api-operator
ENDF
}


function func_operand_request_cr_bai_33()
{
    echo
    echo
   echo "Creating Common Services V3.3 Operand Request for BAI deployments on OCP 4.2+ ..\x1B[0m" >> "${LOG_FILE}"
   operator_source_path=${PARENT_DIR}/descriptors/common-services/crds/operator_operandrequest_cr.yaml
 cat << ENDF > "${operator_source_path}"
apiVersion: operator.ibm.com/v1alpha1
kind: OperandRequest
metadata:
  name: common-service
spec:
  requests:
  - registry: common-service
    operands:
        - name: ibm-cert-manager-operator
        - name: ibm-mongodb-operator
        - name: ibm-iam-operator
        - name: ibm-monitoring-exporters-operator
        - name: ibm-monitoring-prometheusext-operator
        - name: ibm-monitoring-grafana-operator
        - name: ibm-management-ingress-operator
        - name: ibm-licensing-operator
        - name: ibm-metering-operator
        - name: ibm-commonui-operator
ENDF
}


function func_operand_request_cr_nonbai_33()
{
   echo
   echo
   echo "Creating Common Services V3.3 Request Operand for non-BAI deployments on OCP 4.2+ ..\x1B[0m" >> "${LOG_FILE}"
   operator_source_path=${PARENT_DIR}/descriptors/common-services/crds/operator_operandrequest_cr.yaml
 cat << ENDF > "${operator_source_path}"
apiVersion: operator.ibm.com/v1alpha1
kind: OperandRequest
metadata:
  name: common-service
spec:
  requests:
  - registry: common-service
    operands:
        - name: ibm-cert-manager-operator
        - name: ibm-mongodb-operator
        - name: ibm-iam-operator
        - name: ibm-management-ingress-operator
        - name: ibm-licensing-operator
        - name: ibm-metering-operator
        - name: ibm-commonui-operator
ENDF
}


function show_summary(){
    echo
    echo
    printf "\n"
    echo -e "\x1B[1m*******************************************************\x1B[0m"
    echo -e "\x1B[1m                    Summary of input                   \x1B[0m"
    echo -e "\x1B[1m*******************************************************\x1B[0m"
    if [[ ${PLATFORM_VERSION} == "4.4OrLater" ]]; then
        echo -e "\x1B[1;31m1. Cloud platform to deploy: ${PLATFORM_SELECTED} 4.X\x1B[0m"
    else
        echo -e "\x1B[1;31m1. Cloud platform to deploy: ${PLATFORM_SELECTED} ${PLATFORM_VERSION}\x1B[0m"
    fi
    echo -e "\x1B[1;31m2. Project to deploy: ${PROJECT_NAME}\x1B[0m"
    echo -e "\x1B[1;31m3. User selected: ${USER_NAMEUSER_NAME_EMAIL}\x1B[0m"
#    if  [[ $PLATFORM_SELECTED == "ROKS" ]];
#    then
    echo -e "\x1B[1;31m5. Storage Class created: \x1B[0m"
    display_storage_classes_roks
#    fi
    echo -e "\x1B[1m*******************************************************\x1B[0m"
}

function check_csoperator_exists(){
    echo
    echo
    project="common-service"

    check_project=$(${CLI_CMD} get namespace $project --ignore-not-found | wc -l ) >/dev/null 2>&1
    check_operator=$(${CLI_CMD} get csv --all-namespaces |grep "ibm-common-service-operator")
    if [ -n "$check_operator" ]; then
        echo ""
        echo "Found an Existing Installation of IBM Common Services.  The current installation of IBM Common Services will be skipped."  >> "${LOG_FILE}"
        echo "Found an Existing Installation of IBM Common Services.  The current installation of IBM Common Services will be skipped."

        CS_INSTALL="NO"
        exit 1
    fi

}


function get_local_registry_server(){
    echo
    echo
    # For internal/external Registry Server
    printf "\n"
    if [[ "${REGISTRY_TYPE}" == "internal" && ("${OCP_VERSION}" == "4.4OrLater") ]];then
        #This is required for docker/podman login validation.
        printf "\x1B[1mGetting the public image registry or route (e.g., default-route-openshift-image-registry.apps.<hostname>). \n\x1B[0m"
        printf "\x1B[1mThis is required for docker/podman login validation: \x1B[0m"
        local_public_registry_server=$LOCAL_PUBLIC_REGISTRY_SERVER
    fi

    if [[ "${OCP_VERSION}" == "3.11" && "${REGISTRY_TYPE}" == "internal" ]];then
        printf "\x1B[1mGetting the OCP docker registry service name, for example: docker-registry.default.svc:5000/<project-name>: \x1B[0m"
    elif [[ "${REGISTRY_TYPE}" == "internal" && "${OCP_VERSION}" == "4.4OrLater" ]]
    then
        printf "\n"
        printf "\x1B[1mGetting the local image registry (e.g., image-registry.openshift-image-registry.svc:5000/<project>)\n\x1B[0m"
        printf "\x1B[1mThis is required to pull container images and Kubernetes secret creation: \x1B[0m"
        builtin_dockercfg_secrect_name=$(${CLI_CMD} get secret | grep default-dockercfg | awk '{print $1}')
        if [ -z "$builtin_dockercfg_secrect_name" ]; then
            ADMIN_REGISTRY_KEY_SECRET_NAME="admin.registrykey"
        else
            ADMIN_REGISTRY_KEY_SECRET_NAME=$builtin_dockercfg_secrect_name
        fi
    fi

    # convert docker-registry.default.svc:5000/project-name
    # to docker-registry.default.svc:5000\/project-name
    OIFS=$IFS

    delim=""
    joined=""
    for item in "${docker_reg_url_array[@]}"; do
            joined="$joined$delim$item"
            delim="\/"
    done
    IFS=$OIFS
    CONVERT_LOCAL_REGISTRY_SERVER=${joined}
}


function verify_local_registry_password(){

    echo
    echo
    # require to preload image for CP4A image and ldap/db2 image for demo
    printf "\n"

    while true; do
        printf "\x1B[1mHave you pushed the images to the local registry using 'loadimages.sh' (CP4BA images) (Yes/No)? \x1B[0m"
        ans=$PUSHED_LOCAL_IMAGE_REGISTRY
        case "$ans" in
        "y"|"Y"|"yes"|"Yes"|"YES")
            PRE_LOADED_IMAGE="Yes"
            break
            ;;
        "n"|"N"|"no"|"No"|"NO")
            echo -e "\x1B[1;31mPlease pull the images to the local images to proceed.\n\x1B[0m"
            exit 1
            ;;
        *)
            echo -e "Answer must be \"Yes\" or \"No\"\n"
            ;;
        esac
    done

    # Select whice type of image registry to use.
    if [[ "${PLATFORM_SELECTED}" == "OCP" ]]; then
        printf "\n"
        echo -e "\x1B[1mSelect the type of image registry to use: \x1B[0m"
        COLUMNS=12
        options=("Other ( External image registry: abc.xyz.com )")

        PS3='Enter a valid option [1 to 1]: '
        select opt in "${options[@]}"
        do
            case $opt in
                "Openshift Container Platform (OCP) - Internal image registry")
                    REGISTRY_TYPE="internal"
                    break
                    ;;
                "Other ( External image registry: abc.xyz.com )")
                    REGISTRY_TYPE="external"
                    break
                    ;;
                *) echo "invalid option there $REPLY";;
            esac
        done
    else
        REGISTRY_TYPE="external"
    fi

    while [[ $verify_passed == "" && $PRE_LOADED_IMAGE == "Yes" ]]
    do
        get_local_registry_server

        if [[ $LOCAL_REGISTRY_SERVER == docker-registry* || $LOCAL_REGISTRY_SERVER == image-registry* || $LOCAL_REGISTRY_SERVER == default-route-openshift-image-registry* ]] ;
        then
            if [[ $OCP_VERSION == "3.11" ]];then
                if docker login -u "$LOCAL_REGISTRY_USER" -p $(${CLI_CMD} whoami -t) "$LOCAL_REGISTRY_SERVER"; then
                    printf 'Verifying Local Registry passed...\n'
                    verify_passed="passed"
                else
                    printf '\x1B[1;31mLogin failed...\n\x1B[0m'
                    verify_passed=""
                    local_registry_user=""
                    local_registry_server=""
                    echo -e "\x1B[1;31mCheck the local docker registry information and try again.\x1B[0m"
                fi
            elif [[ "$machine" == "Mac" ]]
            then
                if docker login "$local_public_registry_server" -u "$LOCAL_REGISTRY_USER" -p $(${CLI_CMD} whoami -t); then
                    printf 'Verifying Local Registry passed...\n'
                    verify_passed="passed"
                else
                    printf '\x1B[1;31mLogin failed...\n\x1B[0m'
                    verify_passed=""
                    local_registry_user=""
                    local_registry_server=""
                    local_public_registry_server=""
                    echo -e "\x1B[1;31mCheck the local docker registry information and try again.\x1B[0m"
                fi
            elif [[ $OCP_VERSION == "4.4OrLater" ]]
            then
                which podman &>/dev/null
                if [[ $? -eq 0 ]];then
                    if podman login "$local_public_registry_server" -u "$LOCAL_REGISTRY_USER" -p $(${CLI_CMD} whoami -t) --tls-verify=false; then
                        printf 'Verifying Local Registry passed...\n'
                        verify_passed="passed"
                    else
                        printf '\x1B[1;31mLogin failed...\n\x1B[0m'
                        verify_passed=""
                        local_registry_user=""
                        local_registry_server=""
                        local_public_registry_server=""
                        echo -e "\x1B[1;31mCheck the local docker registry information and try again.\x1B[0m"
                    fi
                else
                     if docker login "$local_public_registry_server" -u "$LOCAL_REGISTRY_USER" -p $(${CLI_CMD} whoami -t); then
                        printf 'Verifying Local Registry passed...\n'
                        verify_passed="passed"
                    else
                        printf '\x1B[1;31mLogin failed...\n\x1B[0m'
                        verify_passed=""
                        local_registry_user=""
                        local_registry_server=""
                        local_public_registry_server=""
                        echo -e "\x1B[1;31mCheck the local docker registry information and try again.\x1B[0m"
                    fi
                fi
            fi
        else
            which podman &>/dev/null
            if [[ $? -eq 0 ]];then
                if podman login -u "$LOCAL_REGISTRY_USER" -p "$LOCAL_REGISTRY_PWD"  "$LOCAL_REGISTRY_SERVER" --tls-verify=false; then
                    printf 'Verifying the information for the local docker registry...\n'
                    verify_passed="passed"
                else
                    printf '\x1B[1;31mLogin failed...\n\x1B[0m'
                    verify_passed=""
                    local_registry_user=""
                    local_registry_server=""
                    echo -e "\x1B[1;31mCheck the local docker registry information and try again.\x1B[0m"
                fi
            else
                if docker login -u "$LOCAL_REGISTRY_USER" -p "$LOCAL_REGISTRY_PWD"  "$LOCAL_REGISTRY_SERVER"; then
                    printf 'Verifying the information for the local docker registry...\n'
                    verify_passed="passed"
                else
                    printf '\x1B[1;31mLogin failed...\n\x1B[0m'
                    verify_passed=""
                    local_registry_user=""
                    local_registry_server=""
                    echo -e "\x1B[1;31mCheck the local docker registry information and try again.\x1B[0m"
                fi
            fi
        fi
     done

}


function create_secret_local_registry(){
    echo
    echo
    echo -e "\x1B[1mCreating the secret based on the local docker registry information...\x1B[0m"
    # Create docker-registry secret for local Registry Key
    # echo -e "Create docker-registry secret for Local Registry...\n"
    if [[ $LOCAL_REGISTRY_SERVER == docker-registry* || $LOCAL_REGISTRY_SERVER == image-registry.openshift-image-registry* ]] ;
    then
        builtin_dockercfg_secrect_name=$(${CLI_CMD} get secret | grep default-dockercfg | awk '{print $1}')
        ADMIN_REGISTRY_KEY_SECRET_NAME=$builtin_dockercfg_secrect_name
        # CREATE_SECRET_CMD="${CLI_CMD} create secret docker-registry $ADMIN_REGISTRY_KEY_SECRET_NAME --docker-server=$LOCAL_REGISTRY_SERVER --docker-username=$LOCAL_REGISTRY_USER --docker-password=$(${CLI_CMD} whoami -t) --docker-email=ecmtest@ibm.com"
    else
        ${CLI_CMD} delete secret "$ADMIN_REGISTRY_KEY_SECRET_NAME" -n $PROJECT_NAME >/dev/null 2>&1
#        create_secret
        CREATE_SECRET_CMD="${CLI_CMD} create secret docker-registry $ENTITLED_REGISTRY_KEY_SECRET_NAME --docker-server=$DOCKER_SERVER --docker-username=$DOCKER_USERNAME --docker-password=$ENTITLED_REGISTRY_KEY --docker-email=ecmtest@ibm.com -n $PROJECT_NAME"
        if $CREATE_SECRET_CMD ; then
            echo -e "\x1B[1;34mDone\x1B[0m"
        else
            echo -e "\x1B[1;31mFailed\x1B[0m"
        fi
    fi
}

function add_capabilities(){

#     sc_slow_file_storage_classname: REPLACE_SC_SLOW_FILE_STORAGE_CLASSNAME # "<Required>"
#      sc_medium_file_storage_classname: SC_MEDIUM_FILE_STORAGE_CLASSNAME # "<Required>"
#      sc_fast_file_storage_classname: SC_FAST_FILE_STORAGE_CLASSNAME
    sed "s/REPLACE_SC_SLOW_FILE_STORAGE_CLASSNAME/$SC_SLOW_FILE_STORAGE_CLASSNAME/g" "${ENTERPRISE_FOUNDATION}" > "${ENTERPRISE_FOUNDATION_TMP}"
    sed "s/REPLACE_SC_MEDIUM_FILE_STORAGE_CLASSNAME/$SC_MEDIUM_FILE_STORAGE_CLASSNAME/g" "${ENTERPRISE_FOUNDATION}" > "${ENTERPRISE_FOUNDATION_TMP}"
    sed "s/REPLACE_SC_FAST_FILE_STORAGE_CLASSNAME/$SC_FAST_FILE_STORAGE_CLASSNAME/g" "${ENTERPRISE_FOUNDATION}" > "${ENTERPRISE_FOUNDATION_TMP}"
    echo "Creating IBM CP4BA CR Enterprise Foundation ..."
    ${CLI_CMD} apply -f "${ENTERPRISE_FOUNDATION}"

#    "FileNet Content Manager"
#    "Automation Content Analyzer"
#
#    "Operational Decision Manager"
#
#    "Automation Decision Services"
#
#    "Business Automation Workflow"
#
#    "(a) Workflow Authoring"
#
#    "(b) Workflow Runtime"
#
#    "Business Automation Workflow and Automation Workstream Services"
#
#    "Automation Workstream Services"
#
#    "Business Automation Application"
#
#    "Automation Digital Worker"
#
#    "IBM Automation Document Processing"
#
#    "(a) Development Environment"
#
#    "(b) Runtime Environment"

}

function cp4ba_deployment() {
    echo "Creating tls secret key ..."
    ${CLI_CMD} apply -f "${TLS_SECRET_FILE}" -n "${PROJECT_NAME}"

    echo "Deploying Cloud Pak for Business Automation Capabilities ..."
    ${CLI_CMD} apply -f "${CP4BA_CR_FINAL_FILE}" -n "${PROJECT_NAME}"
}

if [[ $1 == "dev" ]]
then
    CS_INSTALL="YES"

else
    CS_INSTALL="NO"
fi

#allocate_operator_pvc_olm_or_cncf
#echo "Select platform ..."

#echo "Validate cli ..."
#validate_cli # L
#echo "Select user ..."
#select_user
#create_secret_entitlement_registry
#check_platform_version
#fi
#select_deployment_type

#validate_docker_podman_cli
#get_entitlement_registry
#get_storage_class_name
#allocate_operator_pvc_olm_or_cncf
#prepare_olm_install
#prepare_install
#apply_cp4ba_operator

select_platform # Uncomment
#select_user  # Uncomment
validate_cli ## Uncomment
##create_secret_entitlement_registry  # Uncomment
check_platform_version  # Uncomment
#select_deployment_type  # needed, Uncomment later
"${CLI_CMD}" project $PROJECT_NAME >/dev/null 2>&1
#create_project  # Uncomment
##
##
###        apply_cp4ba_operator
validate_docker_podman_cli   # Uncomment
get_entitlement_registry   # Uncomment
get_storage_class_name   # Uncomment
##create_secret_entitlement_registry   # Uncomment
allocate_operator_pvc_olm_or_cncf    # Uncomment
prepare_install
prepare_olm_install
apply_cp4ba_operator
cp4ba_deployment   # Uncomment


#
#if [[ $PLATFORM_SELECTED == "OCP" || $PLATFORM_SELECTED == "ROKS" ]]; then
##    echo "checking version"
#    select_user  # Uncomment
#    validate_cli ## Uncomment
#    create_secret_entitlement_registry  # Uncomment
#    check_platform_version  # Uncomment
##fi
#    select_deployment_type  # Uncomment
#    "${CLI_CMD}" project $PROJECT_NAME >/dev/null 2>&1
#    create_project  # Uncomment
#    ##bind_scc
#    if [[ $SCRIPT_MODE == "OLM" ]];then
#    #     echo "*********** OLM *************"
##        validate_docker_podman_cli
##        get_entitlement_registry
##        get_storage_class_name
##        allocate_operator_pvc_olm_or_cncf
##        prepare_olm_install
#        prepare_install
##        apply_cp4ba_operator
#         validate_docker_podman_cli   # Uncomment
#         get_entitlement_registry   # Uncomment
#         get_storage_class_name   # Uncomment
#         create_secret_entitlement_registry   # Uncomment
#         allocate_operator_pvc_olm_or_cncf    # Uncomment
#         cp4ba_deployment   # Uncomment
#         prepare_olm_install
#         apply_cp4ba_operator
#
#    else
#        validate_docker_podman_cli
#        if [[ $PLATFORM_SELECTED == "other" ]]; then
#            get_entitlement_registry
#        fi
#        if [[ $USE_ENTITLEMENT == "no" ]]; then
#            verify_local_registry_password
#        fi
#        get_storage_class_name
#        if [[ $USE_ENTITLEMENT == "yes" ]]; then
#            create_secret_entitlement_registry
#        fi
#        if [[ $USE_ENTITLEMENT == "no" ]]; then
#            create_secret_local_registry
#        fi
#        allocate_operator_pvc_olm_or_cncf
#        prepare_install
#        apply_cp4ba_operator
#    fi
#fi

#add_capabilities

#prepare_olm_install
#apply_cp4ba_operator # will be removed
#
### create_scc
#
apply_no_root_squash


#############################################
if  [[ $PLATFORM_SELECTED == "OCP" || $PLATFORM_SELECTED == "ROKS" ]];
then
    display_node_name
fi

if [[ $SCRIPT_MODE != "OLM" ]]; then
    show_summary
    check_csoperator_exists

    if [[ $PLATFORM_SELECTED == "OCP" ||  $PLATFORM_SELECTED == "ROKS" ]] && [[ $PLATFORM_VERSION == "4.4OrLater" ]] && [[ $CS_VERSION == "3.4" ]];
    then

        if [ "$CS_INSTALL" != "YES" ]; then
            display_installationprompt
            echo ""

            nohup "${PARENT_DIR}"/scripts/deploy_CS3.4.sh  >> "${LOG_FILE}" 2>&1 &
        else
        echo "Review mode: IBM Common Services will be skipped.."
        fi
    fi

    # Deploy CS 3.3 if OCP 4.2 or 3.11 as per requirements.  The components for CS 3.3 in this case will only be Licensing and Metering (also CommonUI as a base requirment)
    #if  [[[ $PLATFORM_SELECTED == "OCP" ]] && [ $PLATFORM_VERSION == "4.2" ]]] || [[[ $PLATFORM_SELECTED == "OCP" ] && [ $PLATFORM_VERSION == "3.11" ]]]

    if  [[ $PLATFORM_SELECTED == "OCP" ||  $PLATFORM_SELECTED == "ROKS" ]] && [[ $PLATFORM_VERSION == "4.4OrLater" ]] && [[ $CS_VERSION == "3.3" ]];
    then
        echo "IBM Common Services with Metering & Licensing Components will be installed"
            if [ "$CS_INSTALL" != "YES" ]; then
            nohup "${PARENT_DIR}"/scripts/deploy_CS3.3.sh >> "${LOG_FILE}" 2>&1 &
            else
        echo "Review mode: IBM Common Services will be skipped.."
            echo ""
        fi
    fi

    # Deploy CS 3.3 if OCP 3.11
    if  [[ $PLATFORM_SELECTED == "OCP" ]] && [[ $PLATFORM_VERSION == "3.11" ]];
    then
        echo "IBM Common Services with Metering & Licensing Components will be installed"
        if [ "$CS_INSTALL" != "YES" ]; then
            COMMON_SERVICES_INSTALL_DIRECTORY_OCP311=${PARENT_DIR}/descriptors/common-services/scripts/common-services.sh
            sh "${COMMON_SERVICES_INSTALL_DIRECTORY_OCP311}" install --async
        else
            echo "Review mode: IBM Common Services will be skipped.."
        fi
    fi
fi

clean_up
#set the project context back to the user generated one
${CLI_CMD} project ${PROJECT_NAME} > /dev/null


