#!/bin/sh

WAITING_TIME=5

echo "Waiting for Ingress domain to be created"
while [[ -z $(kubectl get route -n openshift-ingress router-default -o jsonpath='{.spec.host}' 2>/dev/null) ]]; do
  sleep $WAITING_TIME
done


ibmcloud config --check-version=false
ibmcloud login -apikey ${IC_API_KEY}
ibmcloud ks cluster config -c ${CLUSTER} --admin

# Retrieve the openshift cluster version
ROKS_VERSION=`oc get clusterversion -o jsonpath='{.items[].status.history[].version}{"\n"}'`
# Round the number down to 0 (e.g. 4.7.40 to 4.7.0)
ROKS_VERSION="${ROKS_VERSION%.*}.0"

ibmcloud oc cluster addon enable openshift-data-foundation -c ${CLUSTER} --version ${ROKS_VERSION} --param "odfDeploy=false"