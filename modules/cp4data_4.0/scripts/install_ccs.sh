#!/bin/bash


# Install ccs operator

wget https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-ccs-1.0.0.tgz


CASE_PACKAGE_NAME="ibm-ccs-1.0.0.tgz"


./cloudctl-linux-amd64 case launch --case ./${CASE_PACKAGE_NAME} \
    --tolerance 1 --namespace ${OP_NAMESPACE}         \
    --action installOperator                        \
    --inventory ccsSetup                            


# Checking if the ccs operator pods are ready and running. 

# checking status of ibm-cpc-ccs-operator

./pod-status-check.sh ibm-cpd-ccs-operator ${OP_NAMESPACE}

# switch zen namespace

oc project ${NAMESPACE} 

cd ../files

# Create CCS CR: 

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" ccs-cr.yaml
fi

echo '*** executing **** oc create -f ccs-cr.yaml'
result=$(oc create -f ccs-cr.yaml)
echo $result

cd ../scripts

# check the CCS cr status

./check-cr-status.sh ccs ccs-cr ${NAMESPACE}  ccsStatus
