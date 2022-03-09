#!/bin/sh

ibmcloud config --check-version=false
ibmcloud login -apikey ${IC_API_KEY}
ibmcloud ks cluster config -c ${CLUSTER} --admin

ibmcloud oc cluster addon disable openshift-data-foundation -c ${CLUSTER} -f