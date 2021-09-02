#!/bin/bash

# db2uoperator complained about missing module
# see if this fixes this
sudo easy_install pip
pip install pyyaml
pip show pyyaml


## Download the case package for data-refinery
wget https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-datarefinery-1.0.0.tgz

# Install data-refinery operator using CLI (OLM)

CASE_PACKAGE_NAME="ibm-datarefinery-1.0.0.tgz"

./cloudctl-linux-amd64 case launch --case ./${CASE_PACKAGE_NAME} \
    --tolerance 1 --namespace ${OP_NAMESPACE}         \
    --action installOperator                        \
    --inventory datarefinerySetup

# Checking if the data-refinery operator pods are ready and running. 
# checking status of ibm-cpd-datarefinery-operator
./pod-status-check.sh ibm-cpd-datarefinery-operator ${OP_NAMESPACE}

# switch to zen namespace
oc project ${NAMESPACE}

echo '*** cd ../files'
cd ../files

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" data-refinery-cr.yaml
fi

# Create data-refinery CR: 

echo '*** executing **** oc create -f data-refinery-cr.yaml'
result=$(oc create -f data-refinery-cr.yaml)
echo $result

echo '*** cd ../scripts'
cd ../scripts

# check the data-refinery cr status
./check-cr-status.sh Datarefinery datarefinery-cr ${NAMESPACE} datarefineryStatus
