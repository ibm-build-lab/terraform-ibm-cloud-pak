#!/bin/bash


podname=$1
namespace=$2

ATTEMPTS=0
TIMEOUT=2160 # 6 hours

status="unknown"
while [ "$status" != "Running" ]
do
  if [ $ATTEMPTS -eq $TIMEOUT ] ; then
    echo "\nTIMED OUT: Waiting for pod status check $podname"
    exit 1
  fi
  pod_name=$(oc get pods -n $namespace | grep $podname | awk '{print $1}' )
  ready_status=$(oc get pods -n $namespace $pod_name  --no-headers | awk '{print $2}')
  pod_status=$(oc get pods -n $namespace $pod_name --no-headers | awk '{print $3}')
  echo $pod_name State - $ready_status, podstatus - $pod_status
  if [ "$ready_status" == "1/1" ] && [ "$pod_status" == "Running" ]
  then 
  status="Running"
  else
  status="starting"
  sleep 10 
  fi
  echo "$pod_name is $status"
  ATTEMPTS=$((ATTEMPTS + 1))
done

