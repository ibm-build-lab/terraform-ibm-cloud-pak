#!/bin/sh

VPC_REGION=us-east

export IAM_TOKEN=$(ibmcloud iam oauth-tokens --output json | jq -r '.iam_token')
export RESOURCE_GROUP=$(ibmcloud target --output json | jq -r '.resource_group.guid')
export CLUSTER=""
ibmcloud target -r $VPC_REGION

echo "Removing attachment from worker-node"
for worker_node_id in `ibmcloud oc workers  --cluster $CLUSTER |grep '^kube' | cut -d ' ' -f 1` ; do 

    attachment_id=`ibmcloud ks storage attachments -c $CLUSTER -w ${worker_node_id} | grep ${CLUSTER} | cut -d ' ' -f 1`
    ibmcloud ks storage attachment rm -c $CLUSTER -w ${worker_node_id} --attachment ${attachment_id}

done

echo "sleeping 5"
sleep 5

echo "Removing storage"
for volume_id in `ibmcloud is volumes | grep ${CLUSTER} | cut -d ' ' -f 1` ; do

    ibmcloud is volume-delete ${volume_id} -f

done