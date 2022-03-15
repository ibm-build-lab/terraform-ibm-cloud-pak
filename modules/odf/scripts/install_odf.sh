#!/bin/sh

ibmcloud config --check-version=false
ibmcloud login -apikey ${IC_API_KEY}
ibmcloud ks cluster config -c ${CLUSTER} --admin

# Retrieve the openshift cluster version
ROKS_VERSION=`oc get clusterversion -o jsonpath='{.items[].status.history[].version}{"\n"}'`

# Round the number down to 0 (e.g. 4.7.40 to 4.7.0)
ROKS_VERSION="${ROKS_VERSION%.*}.0"

ROKS_VERSION_COMP=$(echo "$ROKS_VERSION" | tr -d -c 0-9)

if [ $ROKS_VERSION_COMP -ge 470 ]; then
    echo "Supported version";
    ibmcloud oc cluster addon enable openshift-data-foundation -c ${CLUSTER} --version ${ROKS_VERSION} --param "odfDeploy=false"
else
    echo "Not supported version. Openshift version needs to be 4.7 or higher"; 
    exit 1
fi