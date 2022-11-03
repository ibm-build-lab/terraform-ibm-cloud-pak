#!/bin/bash

# Install wsruntime operator 

cd ../files

sed -i -e "s/OPERATOR_NAMESPACE/${OP_NAMESPACE}/g" wsruntime-sub.yaml

echo '*** executing **** oc create -f wsruntime-sub.yaml'
result=$(oc create -f wsruntime-sub.yaml)
echo $result
sleep 1m

cd ../scripts


# Checking if the wsruntime operator pods are ready and running. 
./pod-status-check.sh ibm-cpd-ws-operator ${OP_NAMESPACE}

cd ../files

# switch zen namespace

oc project ${NAMESPACE}

# Create wsruntime CR: 
sed -i -e "s/CPD_NAMESPACE/${NAMESPACE}/g" wsruntime-cr.yaml
result=$(oc create -f wsruntime-cr.yaml)
echo $result

# check the wsruntime cr status

cd ../scripts

./check-cr-status.sh NotebookRuntime ibm-cpd-ws-runtime-py37 ${NAMESPACE} runtimeStatus
