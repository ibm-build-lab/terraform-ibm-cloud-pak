
#!/bin/bash

NAMESPACE=$1
SERVICE=$2
STORAGECLASS=$3
OVERRIDE=$4

echo "=== Commencing installation of ${SERVICE} ==="

if ! sed -e "s/SERVICE/${SERVICE}/g" -e "s/STORAGECLASS/${STORAGECLASS}/g" -e "s/OVERRIDE/\"${OVERRIDE}\"/g" ../templates/metaoperator.cpd.ibm.com_v1_cpdservice_cr.yaml | oc -n ${NAMESPACE} apply -f -; then
  echo 'Error applying the CPDService manifest'
  exit 1
fi

SLEEP_TIME="60"
RUN_LIMIT=200
i=0

while true; do
  if ! STATUS_LONG=$(oc -n ${NAMESPACE} get cpdservice ${SERVICE}-cpdservice --output=json | jq -c -r '.status'); then
    echo 'Error getting status'
    exit 1
  fi

  echo $STATUS_LONG
  STATUS=$(echo $STATUS_LONG | jq -c -r '.status')

  if [ "$STATUS" == "Ready" ]; then
    break
  fi
  
  if [ "$STATUS" == "Failed" ]; then
    echo '=== Installation has failed ==='
    exit 1
  fi
  
  echo "Sleeping $SLEEP_TIME seconds..."
  sleep $SLEEP_TIME
  
  (( i++ ))
  if [ "$i" -eq "$RUN_LIMIT" ]; then
    echo 'Timed out'
    exit 1
  fi
done

echo "=== ${SERVICE} installed ==="