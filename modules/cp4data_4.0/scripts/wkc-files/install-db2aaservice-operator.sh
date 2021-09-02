#!/bin/bash

CASE_PACKAGE_NAME=$1
NAMESPACE=$2

oc project ${NAMESPACE}

## Install Catalog 

./../cloudctl-linux-amd64 case launch --case ${CASE_PACKAGE_NAME} \
    --namespace openshift-marketplace \
    --action installCatalog \
    --inventory db2aaserviceOperatorSetup \
    --tolerance 1

## Install Operator

./../cloudctl-linux-amd64 case launch --case ${CASE_PACKAGE_NAME} \
    --namespace ${NAMESPACE} \
    --action installOperator \
    --inventory db2aaserviceOperatorSetup \
    --tolerance 1