#!/bin/bash


cd ../files

sed -i -e "s/OPERATOR_NAMESPACE/${OP_NAMESPACE}/g" wos-sub.yaml
echo '*** executing **** oc create -f wos-sub.yaml'
result=$(oc create -f wos-sub.yaml)
echo $result

sleep 1m

# Checking if the wos operator pods are ready and running. 

cd ../scripts

# ./pod-status-check.sh ibm-cpd-wos-operator ${OP_NAMESPACE}
sleep 10m

# switch zen namespace

oc project ${NAMESPACE}

cd ../files

# Create WOS CR:

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" wos-cr.yaml
else
    sed -i -e "s/portworx-shared-gp3/${STORAGE}/g" wos-cr.yaml
fi


sed -i -e "s/CPD_NAMESPACE/${NAMESPACE}/g" wos-cr.yaml
echo '*** executing **** oc create -f wos-cr.yaml'
result=$(oc create -f wos-cr.yaml)
echo $result

cd ../scripts

# check the WOS CR status

# ./check-cr-status.sh WOService aiopenscale ${NAMESPACE} wosStatus
sleep 10m