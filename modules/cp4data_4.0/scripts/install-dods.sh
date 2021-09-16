#!/bin/bash



# Install dods operator

cd ../files

sed -i -e "s/OPERATOR_NAMESPACE/${OP_NAMESPACE}/g" dods-sub.yaml

echo '*** executing **** oc create -f dods-sub.yaml'
result=$(oc create -f dods-sub.yaml)
echo $result
sleep 1m

cd ../scripts

# Checking if the dods operator pods are ready and running. 
# checking status of ibm-cpd-dods-operator
# ./pod-status-check.sh ibm-cpd-dods-operator ${OP_NAMESPACE}
sleep 10m

# switch to zen namespace
oc project ${NAMESPACE}

cd ../files

# Create dods CR: 

echo '*** executing **** oc create -f dods-cr.yaml'
result=$(oc create -f dods-cr.yaml)
echo $result

cd ../scripts

# check the CCS cr status
# ./check-cr-status.sh DODS dods-cr ${NAMESPACE} dodsStatus
sleep 10m