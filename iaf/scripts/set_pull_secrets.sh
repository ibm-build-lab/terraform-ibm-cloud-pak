#!/bin/sh
# Script to set pull secrets and reboot the nodes before IAF can be installed

ibmcloud config --check-version=false
ibmcloud login -apikey ${IC_API_KEY}
ibmcloud ks cluster config -c ${IAF_CLUSTER} --admin

echo "Setting Pull Secret"
oc extract secret/pull-secret -n openshift-config --confirm --to=. 
API_KEY=$(echo -n "${IAF_ENTITLED_REGISTRY_USER}:${IAF_ENTITLED_REGISTRY_KEY}" | base64 | tr -d '[:space:]')
jq --arg apikey ${API_KEY} --arg registry "${IAF_ENTITLED_REGISTRY}" '.auths += {($registry): {"auth":$apikey}}' .dockerconfigjson > .dockerconfigjson-new
mv .dockerconfigjson-new .dockerconfigjson
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson  
rm .dockerconfigjson

worker_count=0
ibmcloud ks workers --cluster ${IAF_CLUSTER}

echo "Rebooting workers, could take up to 60 minutes"
# $IAF_CLUSTER_ON_VPC ? action=replace : action=reload
[[ $IAF_CLUSTER_ON_VPC == "true" ]] && action=replace || action=reload
for worker in $(ibmcloud ks workers --cluster ${IAF_CLUSTER} | grep kube- | awk '{ print $1 }'); 
do echo "reloading worker";
  ibmcloud ks worker $action --cluster ${IAF_CLUSTER} -w $worker -f; 
  ((worker_count++))
done

echo "Waiting for workers to delete ..."
oc get nodes | grep SchedulingDisabled
result=$?
counter=0
while [[ "${result}" -eq 0 ]]
do
    if [[ $counter -gt 20 ]]; then
        echo "Workers did not delete within 60 minutes.  Please investigate"
        exit 1
    fi
    counter=$((counter + 1))
    echo "Waiting for workers to delete"
    sleep 180s
    oc get nodes | grep SchedulingDisabled
    result=$?
done

# Loop until all workers are in Ready state
result=$(oc get nodes | grep " Ready" | awk '{ print $2 }' | wc -l)
counter=0
echo "Waiting for all $worker_count workers to restart"
while [[ $result -lt $worker_count ]]
do
    if [[ $counter -gt 20 ]]; then
        echo "Workers did not reload within 60 minutes.  Please investigate"
        exit 1
    fi
    counter=$((counter + 1))
    echo "Waiting for all $worker_count workers to restart"
    sleep 180s
    result=$(oc get nodes | grep " Ready" | awk '{ print $2 }' | wc -l)
done

