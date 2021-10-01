#!/bin/bash

# Install db2oltp operator 
oc project ${OP_NAMESPACE}

cd ../files

sed -i -e "s/OPERATOR_NAMESPACE/${OP_NAMESPACE}/g" db2oltp-sub.yaml
echo '*** executing **** oc create -f db2oltp-sub.yaml'
result=$(oc create -f db2oltp-sub.yaml)
echo $result

sleep 1m

cd ../scripts

# Checking if the db2oltp operator podb2oltp are ready and running. 	
# checking status of db2oltp-operator	
./pod-status-check.sh ibm-db2oltp-cp4d-operator ${OP_NAMESPACE}

# switch to zen namespace	
oc project ${NAMESPACE}

cd ../files

# Create db2oltp CR: 	
sed -i -e "s/REPLACE_NAMESPACE/${NAMESPACE}/g" db2oltp-cr.yaml
echo '*** executing **** oc create -f db2oltp-cr.yaml'
result=$(oc create -f db2oltp-cr.yaml)
echo $result

cd ../scripts

# check the CCS cr status	
./check-cr-status.sh Db2oltpService db2oltp-cr ${NAMESPACE} db2oltpStatus
