#!/bin/bash

# Download the case package for ds
wget https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-datastage-4.0.1.tgz


# Install ds operator using CLI (OLM)	

CASE_PACKAGE_NAME="ibm-datastage-4.0.1.tgz"

oc project ${OP_NAMESPACE}

## Install Operator

./cloudctl-linux-amd64 case launch --action installOperator \
    --case ${CASE_PACKAGE_NAME} \
    --inventory datastageOperatorSetup \
    --namespace ${OP_NAMESPACE} \
    --tolerance 1

sleep 1m
# Checking if the ds operator pods are ready and running. 	
# checking status of ds-operator	
# ./pod-status-check.sh datastage-operator ${OP_NAMESPACE}
sleep 10m

# switch to zen namespace	
oc project ${NAMESPACE}

cd ../files

# Create ds CR: 	
echo '*** executing **** oc create -f ds-cr.yaml'
result=$(oc create -f ds-cr.yaml)
echo $result

cd ../scripts

# check the CCS cr status	
# ./check-cr-status.sh DataStageService datastage-cr ${NAMESPACE} dsStatus
sleep 10m