NAMESPACE="aiops"
SLEEP_TIME="10"
RUN_LIMIT=200
i=0

# while true; do
#   if ! STATUS_LONG=$(oc -n ${NAMESPACE} get  AIManager aiops-aimanager --output=json | jq -c -r '.status'); then
#     echo 'Error getting status'
#     exit 1
#   fi

#   echo $STATUS_LONG
#   STATUS=$(echo $STATUS_LONG | jq -c -r '.conditions[0].type')

#   if [ "$STATUS" == "Ready" ]; then
#     break
#   fi
  
#   if [ "$STATUS" == "Failed" ]; then
#     echo '=== Installation has failed ==='
#     exit 1
#   fi
  
#   echo "Sleeping $SLEEP_TIME seconds..."
#   sleep $SLEEP_TIME
  
#   (( i++ ))
#   if [ "$i" -eq "$RUN_LIMIT" ]; then
#     echo 'Timed out'
#     exit 1
#   fi
# done

FAKE_STATUS='{"imagePullSecret":"Found","licenseacceptance":"Accepted","locations":{},"phase":"Running","size":"medium","storageclass":"ibmc-file-gold-gid","storageclasslargeblock":"ibmc-file-gold-gid"}'
FAKE_UPDATED='{"imagePullSecret":"Found","licenseacceptance":"Accepted","locations":{"cloudPakUiUrl":"https://cpd-aiops.emc-aiops-aiops-cluster-c0b572361ba41c9eef42d4d51297b04b-0000.us-south.containers.appdomain.cloud","csAdminHubUrl":"https://cp-console.emc-aiops-aiops-cluster-c0b572361ba41c9eef42d4d51297b04b-0000.us-south.containers.appdomain.cloud"},"phase":"Running","size":"medium","storageclass":"ibmc-file-gold-gid","storageclasslargeblock":"ibmc-file-gold-gid"}'

SLEEP_TIME="5"
RUN_LIMIT=200
i=0

count=0
while true; do
  # if ! STATUS_LONG=$(oc -n ${NAMESPACE} get installation.orchestrator.aiops.ibm.com ibm-cp-watson-aiops --output=json | jq -c -r '.status'); then
  #   echo 'Error getting status'
  #   exit 1
  # fi

  if [ $count -le 3 ]; then
    STATUS_LONG=$FAKE_STATUS
  else
    STATUS_LONG=$FAKE_UPDATED
  fi
  echo $STATUS_LONG

  STATUS=$(echo $STATUS_LONG | jq -c -r '.locations')
  if [ $STATUS == "{}" ]; then
    echo "I'm empty.."
  else
    echo "I got something.."
    echo $STATUS
    break
  fi
  
  echo "Sleeping $SLEEP_TIME seconds..."
  sleep $SLEEP_TIME
  
  (( i++ ))
  if [ "$i" -eq "$RUN_LIMIT" ]; then
    echo 'Timed out'
    exit 1
  fi

  (( count++ ))
done