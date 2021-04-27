#!/bin/bash
# Script to set pull secrets and reboot the nodes before IAF can be installed

echo "Setting Pull Secret"
oc extract secret/pull-secret -n openshift-config --confirm --to=. 
API_KEY=`echo -n "${IAF_ENTITLED_REGISTRY_USER}:${IAF_ENTITLED_REGISTRY_KEY}"  | base64`
echo $API_KEY
jq --arg apikey ${API_KEY} --arg registry "${IAF_ENTITLED_REGISTRY}" '.auths += {($registry): {"auth":$apikey}}' .dockerconfigjson > .dockerconfigjson-new
mv .dockerconfigjson-new .dockerconfigjson
cat .dockerconfigjson
oc set data secret/pull-secret -n openshift-config --from-file=.dockerconfigjson  
rm .dockerconfigjson

if [[ $IAF_CLUSTER_ON_VPC == "true" ]]; then
  action=replace
else
  action=reload
fi

worker_count=0
for worker in $(ibmcloud ks workers --cluster ${IAF_CLUSTER} | grep kube | awk '{ print $1 }'); 
do echo "reloading worker";
  echo "ibmcloud oc worker $action --cluster ${IAF_CLUSTER} -w $worker -f";
  ibmcloud oc worker $action --cluster ${IAF_CLUSTER} -w $worker -f; 
  worker_count=$((worker_count + 1))
done

echo "Completed setting pull secrets and restarting workers"
echo "Waiting for workers to restart ..."
oc get nodes | grep SchedulingDisabled
result=$?
counter=0
while [[ "${result}" -eq 0 ]]
do
    if [[ $counter -gt 20 ]]; then
        echo "Workers did not reload within 60 minutes.  Please investigate"
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
while [[ $result -lt $worker_count ]]
do
    if [[ $counter -gt 10 ]]; then
        echo "Workers did not reload within 60 minutes.  Please investigate"
        exit 1
    fi
    counter=$((counter + 1))
    echo "Waiting for all $worker_count workers to restart"
    sleep 180s
    result=$(oc get nodes | grep " Ready" | awk '{ print $2 }' | wc -l)
done

