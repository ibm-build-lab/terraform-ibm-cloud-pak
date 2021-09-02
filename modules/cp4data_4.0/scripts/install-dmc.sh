#!/bin/bash

# Case package. 

wget https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-dmc-4.0.0.tgz


CASE_PACKAGE_NAME="ibm-dmc-4.0.0.tgz"

oc project ${OP_NAMESPACE}

## Install Catalog 

./cloudctl-linux-amd64 case launch --action installCatalog \
    --case ${CASE_PACKAGE_NAME} \
    --inventory dmcOperatorSetup \
    --namespace openshift-marketplace \
    --tolerance 1

## Install Operator

./cloudctl-linux-amd64 case launch  --action installOperator \
    --case ${CASE_PACKAGE_NAME} \
    --inventory dmcOperatorSetup \
    --namespace ${OP_NAMESPACE} \
    --tolerance 1

sleep 5m

oc project ${NAMESPACE} 

cd ../files

# Create dmc CR:

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" dmc-cr.yaml
fi

sed -i -e "s/CPD_NAMESPACE/${NAMESPACE}/g" dmc-cr.yaml
echo '*** executing **** oc create -f dmc-cr.yaml'
result=$(oc create -f dmc-cr.yaml)
echo $result

cd ../scripts

# checking status of dmc-operator
./pod-status-check.sh ibm-dmc-controller ${OP_NAMESPACE}

# check the mc cr status
./check-cr-status.sh dmcaddon dmcaddon-cr ${NAMESPACE} dmcAddonStatus
