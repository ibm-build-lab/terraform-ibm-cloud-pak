#!/bin/bash

echo '*** Seeing if cloudctl binary path works ***'
result=$(./cloudctl-linux-amd64)
echo $result

wget https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-linux-amd64.tar.gz
wget https://github.com/IBM/cloud-pak-cli/releases/latest/download/cloudctl-linux-amd64.tar.gz.sig

tar -xvf cloudctl-linux-amd64.tar.gz

echo '*** Seeing if cloudctl binary path works ***'
result=$(./cloudctl-linux-amd64)
echo $result

wget https://raw.githubusercontent.com/IBM/cloud-pak/master/repo/case/ibm-wsl-2.0.0.tgz

# Install wsl operator using CLI (OLM)

CASE_PACKAGE_NAME="ibm-wsl-2.0.0.tgz"

oc project ${OP_NAMESPACE}

./cloudctl-linux-amd64  case launch --case ./${CASE_PACKAGE_NAME} \
    --tolerance 1 \
    --namespace openshift-marketplace \
    --action installCatalog \
    --inventory wslSetup 

./cloudctl-linux-amd64 case launch --case ./${CASE_PACKAGE_NAME} \
    --tolerance 1 \
    --namespace ${OP_NAMESPACE}         \
    --action installOperator \
    --inventory wslSetup 
    # --args "--registry cp.icr.io"

# Checking if the wsl operator pods are ready and running. 

# ./pod-status-check.sh ibm-cpd-ws-operator ${OP_NAMESPACE}
sleep 10m
# switch zen namespace

oc project ${NAMESPACE}

cd ../files

# Create wsl CR:

# ****** sed command for classic goes here *******
if [[ ${ON_VPC} == false ]] ; then
    sed -i -e "s/portworx-shared-gp3/ibmc-file-gold-gid/g" wsl-cr.yaml #storageClass
    sed -i -e "/storageVendor/d" wsl-cr.yaml #storageVendor
fi

result=$(oc create -f wsl-cr.yaml)
echo $result

cd ../scripts

# check the CCS cr status

# ./check-cr-status.sh ws ws-cr ${NAMESPACE} wsStatus
sleep 10m