#!/bin/bash




## Install Operator

cd ../files

sed -i -e "s/OPERATOR_NAMESPACE/${OP_NAMESPACE}/g" spark-sub.yaml

echo '*** executing **** oc create -f spark-sub.yaml'
result=$(oc create -f spark-sub.yaml)
echo $result
sleep 1m

cd ../scripts

# Checking if the spark operator pods are ready and running. 
# checking status of ibm-cpd-ae-operator
# ./pod-status-check.sh ibm-cpd-ae-operator ${OP_NAMESPACE}
sleep 10m

#switch to zen namespace

oc project ${NAMESPACE}

cd ../files

# Create spark CR:

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" spark-cr.yaml
fi

sed -i -e "s/BUILD_NUMBER/4.0.0/g" spark-cr.yaml
echo '*** executing **** oc create -f spark-cr.yaml'
result=$(oc create -f spark-cr.yaml)
echo $result

cd ../scripts

# check the spark cr status
# ./check-cr-status.sh AnalyticsEngine analyticsengine-cr ${NAMESPACE} analyticsengineStatus
sleep 10m