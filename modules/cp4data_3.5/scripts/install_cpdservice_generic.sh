
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

SLEEP_TIME="60" #  1 min
SERVICE_DELETION_TIMEOUT_LIMIT=10 # minutes
RUN_LIMIT=4 # Runs '5' times
service_timeout_count=0
run_limit_count=0

while true; do
  if ! STATUS_LONG=$(oc -n ${NAMESPACE} get cpdservice ${SERVICE}-cpdservice --output=json | jq -c -r '.status'); then
    echo 'Error getting status'
    exit 1
  fi

  echo $STATUS_LONG
  STATUS=$(echo $STATUS_LONG | jq -c -r '.status')

  # If the service has been restarted RUN_LIMIT times, it will quit and time out.
  if [ "$run_limit_count" -eq "$RUN_LIMIT" ]; then
    echo 'Timed out'
    exit 1
  fi

  if [ "$STATUS" == "Ready" ]; then
    break
  fi
  
  if [ "$STATUS" == "Failed" ]; then
    echo "=== ${SERVICE} Installation has failed ==="

    echo "Deleting and retrying ${SERVICE} installation"
    oc -n ${NAMESPACE} delete cpdservice ${SERVICE}-cpdservice

    # Set counter for potential run away deletion timeout
    service_deletion_timeout_count=0
    while true; do

      # If the deletion takes too long to delete (SERVICE_TIMEOUT_LIMIT), it will fail and exit
      if [ "$service_deletion_timeout_count" -eq "$SERVICE_DELETION_TIMEOUT_LIMIT" ]; then
        echo "=== ${SERVICE} Installation has failed ==="
        echo "Deleting ${SERVICE} from ${NAMESPACE} has failed."
        exit 1
      fi

      echo "Waiting for ${SERVICE} to finish deleting..."
      if [ -z $(oc -n ${NAMESPACE} get cpdservice ${SERVICE}-cpdservice | awk '{print $1}') ]; then
        break
      fi

      sleep $SLEEP_TIME
      (( service_deletion_timeout_count++ ))
    done

    echo "Recreating ${SERVICE} service..."
    sed -e "s/SERVICE/${SERVICE}/g" -e "s/STORAGECLASS/${STORAGECLASS}/g" -e "s/OVERRIDE/\"${OVERRIDE}\"/g" ../templates/metaoperator.cpd.ibm.com_v1_cpdservice_cr.yaml | oc -n ${NAMESPACE} apply -f -

    (( run_limit_count++ ))
  fi
  
  echo "Sleeping $SLEEP_TIME seconds..."
  sleep $SLEEP_TIME
  
done

echo "=== ${SERVICE} installed ==="