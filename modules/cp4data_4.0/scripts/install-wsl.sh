#!/bin/bash



# Install wsl operator 

cd ../files

sed -i -e "s/OPERATOR_NAMESPACE/${OP_NAMESPACE}/g" wsl-sub.yaml

echo '*** executing **** oc create -f wsl-sub.yaml'
result=$(oc create -f wsl-sub.yaml)
echo $result
sleep 1m

cd ../scripts

# Checking if the wsl operator pods are ready and running. 

# ./pod-status-check.sh ibm-cpd-ws-operator ${OP_NAMESPACE}
sleep 10m
# switch zen namespace

cd ../files

oc project ${NAMESPACE}

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" wsl-cr.yaml
fi

# Create wsl CR: 
sed -i -e s#CPD_NAMESPACE#${NAMESPACE}#g wsl-cr.yaml
result=$(oc create -f wsl-cr.yaml)
echo $result

cd ../scripts

# check the WSL cr status

# ./check-cr-status.sh ws ws-cr ${NAMESPACE} wsStatus
sleep 10m