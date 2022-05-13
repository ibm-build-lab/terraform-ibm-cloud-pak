#!/bin/bash

SERVICE=$1
CRNAME=$2
NAMESPACE=$3
SERVICE_STATUS=$4
STATUS=$(oc get $SERVICE $CRNAME -n $NAMESPACE -o json | jq .status.$SERVICE_STATUS | xargs) 

ATTEMPTS=0
TIMEOUT=300 # 5 hours

# while  [[ ! $STATUS =~ ^(Completed|Complete)$ ]]; do
while [[ $STATUS != "Complete" && $STATUS != "Completed" ]];do
    if [ $ATTEMPTS -eq $TIMEOUT ] ; then
        echo "Took longer than 5 hours: Waiting for check cr status $CRNAME"
        exit 1
    fi
    echo "$CRNAME is Installing!!!!"
    sleep 120 
    STATUS=$(oc get $SERVICE $CRNAME -n $NAMESPACE -o json | jq .status.$SERVICE_STATUS | xargs) 
    if [ " $STATUS" == "Failed" ]
    then
        echo "**********************************"
        echo "$CRNAME Installation Failed!!!!"
        echo "**********************************"
        exit
    fi
    ATTEMPTS=$((ATTEMPTS + 1))
done 
echo "*************************************"
echo "$CRNAME Installation Finished!!!!"
echo "*************************************"