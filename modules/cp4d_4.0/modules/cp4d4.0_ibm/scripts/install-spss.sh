#!/bin/bash



# # Install spss operator 

cd ../files

sed -i -e "s/OPERATOR_NAMESPACE/${OP_NAMESPACE}/g" spss-sub.yaml

echo '*** executing **** oc create -f spss-sub.yaml'
result=$(oc create -f spss-sub.yaml)
echo $result
sleep 1m

cd ../scripts

# Checking if the spss operator pods are ready and running. 
# checking status of ibm-cpd-spss-operator
./pod-status-check.sh ibm-cpd-spss-operator ${OP_NAMESPACE}

# switch to zen namespace
oc project ${NAMESPACE}

cd ../files

# Create spss CR:

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" spss-cr.yaml
else
    sed -i -e "s/portworx-shared-gp3/${STORAGE}/g" spss-cr.yaml
fi

sed -i -e "s/REPLACE_NAMESPACE/${NAMESPACE}/g" spss-cr.yaml
echo '*** executing **** oc create -f spss-cr.yaml'
result=$(oc create -f spss-cr.yaml)
echo $result

cd ../scripts

# check the CCS cr status
./check-cr-status.sh spss spss-cr ${NAMESPACE} spssmodelerStatus
