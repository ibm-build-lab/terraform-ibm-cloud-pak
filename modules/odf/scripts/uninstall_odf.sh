#!/bin/sh

ibmcloud config --check-version=false
ibmcloud login -apikey ${IC_API_KEY}
ibmcloud ks cluster config -c ${CLUSTER} --admin

# Delete OCS/ODF operator

# 1.Check the current version of the subscribed Operator
CURRENT_CSV=`kubectl get subscription ocs-subscription -n openshift-storage -o jsonpath='{.status.currentCSV}{"\n"}'`
# 2.Delete the Operator’s Subscription
kubectl delete subscription ocs-subscription -n openshift-storage
# 3.Delete the CSV for the Operator in the target namespace using the currentCSV value from the previous step
kubectl delete clusterserviceversion ${CURRENT_CSV} -n openshift-storage
# Disable OCS/ODF addon
ibmcloud ks cluster addon disable openshift-data-foundation -c ${CLUSTER} -f