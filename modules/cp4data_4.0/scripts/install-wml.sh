#!/bin/bash

# Install wml operator 

cd ../files

sed -i -e "s/OPERATOR_NAMESPACE/${OP_NAMESPACE}/g" wml-sub.yaml

echo '*** executing **** oc create -f wml-sub.yaml'
result=$(oc create -f wml-sub.yaml)
echo $result
sleep 1m

# Checking if the wml operator pods are ready and running. 

cd ../scripts

# checking status of ibm-watson-wml-operator

./pod-status-check.sh ibm-cpd-wml-operator ${OP_NAMESPACE}

# switch zen namespace

oc project ${NAMESPACE}

cd ../files

# Create wml CR: 

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" wml-cr.yaml
    sed -i -e "/storageVendor/d" wml-cr.yaml #storageVendor
else
    sed -i -e "s/portworx-shared-gp3/${STORAGE}/g" wml-cr.yaml
fi

sed -i -e "s/CPD_NAMESPACE/${NAMESPACE}/g" wml-cr.yaml
echo '*** executing **** oc create -f wml-cr.yaml'
result=$(oc create -f wml-cr.yaml)
echo $result

cd ../scripts

# check the WML cr status

./check-cr-status.sh WmlBase wml-cr ${NAMESPACE} wmlStatus
