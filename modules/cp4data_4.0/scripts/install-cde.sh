#!/bin/bash

## Install Operator

cd ../files

sed -i -e "s/OPERATOR_NAMESPACE/${OP_NAMESPACE}/g" cde-sub.yaml

echo '*** executing **** oc create -f cde-sub.yaml'
result=$(oc create -f cde-sub.yaml)
echo $result
sleep 1m

cd ../scripts


# Checking if the cde operator pods are ready and running. 
# checking status of ibm-cde-operator
./pod-status-check.sh ibm-cde-operator ${OP_NAMESPACE}

# switch to zen namespace
oc project ${NAMESPACE}

# Create cde CR:

cd ../files

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" cde-cr.yaml
fi

sed -i -e "s/REPLACE_NAMESPACE/${NAMESPACE}/g" cde-cr.yaml
echo '*** executing **** oc create -f cde-cr.yaml'
result=$(oc create -f cde-cr.yaml)
echo $result

cd ../scripts

# check the cde cr status
./check-cr-status.sh CdeProxyService cde-cr ${NAMESPACE} cdeStatus
