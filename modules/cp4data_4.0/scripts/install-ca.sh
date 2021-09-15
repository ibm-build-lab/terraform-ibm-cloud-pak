#!/bin/bash



# Install ca operator 
oc project ${OP_NAMESPACE}

cd ../files

sed -i -e s#OPERATOR_NAMESPACE#${OP_NAMESPACE}#g ca-sub.yaml

echo '*** executing **** oc create -f ca-sub.yaml'
result=$(oc create -f ca-sub.yaml)
echo $result
sleep 1m

cd ../scripts
# Checking if the ca operator pods are ready and running. 	
# checking status of ca-operator	
# ./pod-status-check.sh ca-operator ${OP_NAMESPACE}
sleep 10m

# switch to zen namespace	
oc project ${NAMESPACE}

cd ../files

# Create ca CR:

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" ca-cr.yaml
fi

sed -i -e "s/REPLACE_NAMESPACE/${NAMESPACE}/g" ca-cr.yaml
echo '*** executing **** oc create -f ca-cr.yaml'
result=$(oc create -f ca-cr.yaml)
echo $result

cd ../scripts

# check the CCS cr status	
# ./check-cr-status.sh CAService ca-cr ${NAMESPACE} caAddonStatus
sleep 10m