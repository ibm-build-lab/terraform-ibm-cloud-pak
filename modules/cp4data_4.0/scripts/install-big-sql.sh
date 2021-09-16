#!/bin/bash


# Install bigsql operator 
oc project ${OP_NAMESPACE}

cd ../files

sed -i -e "s/OPERATOR_NAMESPACE/${OP_NAMESPACE}/g" big-sql-sub.yaml

echo '*** executing **** oc create -f big-sql-sub.yaml'
result=$(oc create -f big-sql-sub.yaml)
echo $result
sleep 1m

cd ../scripts

# Checking if the bigsql operator pods are ready and running. 
# checking status of ibm-bigsql-operator
# ./pod-status-check.sh ibm-bigsql-operator ${OP_NAMESPACE}
sleep 10m

# switch to zen namespace
oc project ${NAMESPACE}

## Install Custom Resource bigsql 

sed -i -e s#REPLACE_NAMESPACE#${NAMESPACE}#g big-sql-cr.yaml
echo '*** executing **** oc create -f big-sql-cr.yaml'
result=$(oc create -f big-sql-cr.yaml)
echo $result

# check the bigsql cr status
# ./check-cr-status.sh bigsqlservice bigsql-service ${NAMESPACE} reconcileStatus
sleep 10m