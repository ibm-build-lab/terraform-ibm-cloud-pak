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

OC_CMD=oc
PROJECT_NAME="cp4ba"

DOCKER_SERVER="cp.icr.io"
DOCKER_USERNAME="cp"
ENTITLED_REGISTRY_KEY="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJJQk0gTWFya2V0cGxhY2UiLCJpYXQiOjE2Mjk5MTE0OTgsImp0aSI6ImJkNGE3OWZlYWQ3NzRjZDU4ZTIwNDdmN2JiOTc1MTI3In0.EMm6U4y6Rmuba5owRd4N-HNugmhMxXNNbSuqVVl-lnQ"
DOCKER_USER_EMAIL="joel.goddot@ibm.com"

OPERATOR_PVC_FILE_CP=${PARENT_DIR}/files/cp4ba_pvc_tmp.yaml
OPERATOR_PVC_TEMPLATE=${PARENT_DIR}/templates/cp4ba_pvc.yaml.tmpl

cp "${OPERATOR_PVC_TEMPLATE}" "${OPERATOR_PVC_FILE_CP}"
SLOW_STORAGE_CLASS_NAME="ibmc-file-bronze-gid"


function allocate_operator_pvc(){
    sed -i.tmp "s|REPLACE_PROJECT_NAME|$PROJECT_NAME|g" "${OPERATOR_PVC_FILE_CP}"
    sed -i.tmp "s|REPLACE_STORAGE_CLASS|$SLOW_STORAGE_CLASS_NAME|g" "${OPERATOR_PVC_FILE_CP}"

    echo -e "\x1B[1mApplying the Persistent Volumes Claim (PVC) for the Cloud Pak operator by using the storage classname: ${SLOW_STORAGE_CLASS_NAME}...\x1B[0m"
    CREATE_PVC_RESULT=$("${OC_CMD}" apply -f "${OPERATOR_PVC_FILE}" -n "$PROJECT_NAME")   # "${CLI_CMD} apply -f ${OPERATOR_PVC_FILE_TMP} -n $PROJECT_NAME"

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
    until ${OC_CMD} get pvc -n $PROJECT_NAME | grep cp4ba-shared-log-pvc | grep -q -m 1 "Bound" || [ $ATTEMPTS -eq $TIMEOUT ]; do
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

allocate_operator_pvc