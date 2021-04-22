#!/bin/sh

# Required input parameters
# - IAM_TOKEN
# - RESOURCE_GROUP
# - VPC_REGION=us-east
# - CLUSTER
# - STORAGE_REGION
# - CAPACITY

# IAM_TOKEN=${IAM_TOKEN}
RESOURCE_GROUP=${RESOURCE_GROUP}
VPC_REGION=${VPC_REGION}
IBMCLOUD_API_KEY=${IBMCLOUD_API_KEY}
CLUSTER=${CLUSTER}
STORAGE_REGION=${STORAGE_REGION}
STORAGE_CAPACITY=${STORAGE_CAPACITY:-200}

ibmcloud api cloud.ibm.com
ibmcloud login --apikey ${IBMCLOUD_API_KEY}
ibmcloud target -r $VPC_REGION
ibmcloud target -g ${RESOURCE_GROUP}

export IAM_TOKEN=$(ibmcloud iam oauth-tokens --output json | jq -r '.iam_token')
# export RESOURCE_GROUP=$(ibmcloud target --output json | jq -r '.resource_group.guid')
# export CLUSTER=""

# Creates a volume per worker updating the vol number
echo "[INFO] Creating volumes for each worker node."
for ((count=1;count<=`ibmcloud oc workers --cluster $CLUSTER |grep -c '^kube'`;count++)); do
    ibmcloud is volume-create "${CLUSTER}-vol0${count}" 10iops-tier $STORAGE_REGION --capacity $STORAGE_CAPACITY
    # TODO Check for creation
done

# Attach the volume to each worker node
echo "[INFO] Attempting to attach each volume to a worker node."
sleep 5

# Obtains a list of worker_ids
worker_count=1
for worker_node_id in `ibmcloud oc workers  --cluster $CLUSTER |grep '^kube' | cut -d ' ' -f 1` ; do 
    echo "[INFO] Grabbing volume_id for ${CLUSTER}-vol0${worker_count}"
    volume_id=`ibmcloud is volumes | grep ${CLUSTER}-vol0${worker_count} | cut -d ' ' -f 1`

    echo "[INFO] Creating attachment for 
       worker: ${worker_node_id}
       volume_id: ${volume_id}  
       cluster: ${CLUSTER}"
    create_attachment_output=`ibmcloud ks storage attachment create --cluster $CLUSTER --volume ${volume_id} --worker ${worker_node_id}`
    
    echo "[INFO] Checking for creation of attachment"
    # Check to see if they created an attachment: OK/FAILED
    if ! [[ -z $(echo ${create_attachment_output} | grep "OK") ]]; then
        echo "[SUCCESS] Volume attachment was created."
    else
        echo "[ERROR] Volume failed to create, exiting..."
        exit 1
    fi
    
    sleep 1; 
    worker_count=$((worker_count+1))
done

echo "[INFO] Waiting 1 minute..."
sleep 60

worker_count=1
echo "[INFO] Checking for attachment success.."
for worker_node_id in `ibmcloud oc workers  --cluster ${CLUSTER} |grep '^kube' | cut -d ' ' -f 1` ; do 
    fail_count=0
    volume="${CLUSTER}-vol0${worker_count}"

    echo "[INFO] Verifying attachment for ${worker_node_id}"
    while true; do
        echo "[INFO] Attempting getAttachments curl, retrying ${fail_count} times"
        get_attachment_output=$(curl -s -X GET "https://containers.cloud.ibm.com/v2/storage/getAttachments?cluster=$CLUSTER&worker=${worker_node_id}" --header "X-Auth-Resource-Group-ID: $RESOURCE_GROUP" --header "Authorization: $IAM_TOKEN")

        if [[ "${get_attachment_output}" == *"volume_attachments"* ]] && [[ $(echo ${get_attachment_output} | jq -r --arg v "${volume}" '.volume_attachments[] | select(.volume.name==$v) | .status') ==  "attached" ]]; then
            echo "[SUCCESS] Verified successfully. Volume attached: ${volume} to ${worker_node_id}"
            break
        fi

        if [ $fail_count -ge 15 ]; then
            echo "[ERROR] Failed ${fail_count} times. Please check for any problems: ibmcloud ks storage attachment ls -c ${CLUSTER} -w ${worker_node_id}"
          exit 1
        fi

        sleep 5
        fail_count=$((fail_count+1)) 
    done

    worker_count=$((worker_count+1))
done

echo "[INFO] Waiting 1 minute..."
sleep 60
