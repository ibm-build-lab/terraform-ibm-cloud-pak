#!/bin/bash


# Install db2wh operator 
oc project ${OP_NAMESPACE}

cd ../files

sed -i -e s#OPERATOR_NAMESPACE#${OP_NAMESPACE}#g db2wh-sub.yaml

echo '*** executing **** oc create -f db2wh-sub.yaml'
result=$(oc create -f db2wh-sub.yaml)
echo $result
sleep 1m

cd ../scripts

# Checking if the db2wh operator podb2wh are ready and running. 	
# checking status of db2wh-operator	
# ./pod-status-check.sh ibm-db2wh-cp4d-operator ${OP_NAMESPACE}
sleep 10m

# switch to zen namespace	
oc project ${NAMESPACE}

cd ../files

# Create db2wh CR: 	
echo '*** executing **** oc create -f db2wh-cr.yaml'
result=$(oc create -f db2wh-cr.yaml)
echo $result

cd ../scripts

# check the CCS cr status	
# ./check-cr-status.sh db2whService db2wh-cr ${NAMESPACE} db2whStatus
sleep 10m