#!/bin/sh

ibmcloud config --check-version=false
ibmcloud login -apikey ${IC_API_KEY}
ibmcloud ks cluster config -c ${CLUSTER} --admin

# Retrieve the openshift cluster version
ROKS_VERSION=`oc get clusterversion -o jsonpath='{.items[].status.history[].version}{"\n"}'`
# Round the number down to 0 (e.g. 4.7.40 to 4.7.0)
ROKS_VERSION="${ROKS_VERSION%.*}.0"

ibmcloud oc cluster addon disable openshift-data-foundation -c ${CLUSTER}