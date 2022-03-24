#!/bin/sh

# NAMESPACE="cp4aiops"

########################
#
# A signed certificate is needed on the NGNIX pods for the Slack and Teams integrations.
#
#######################

AUTO_UI_INSTANCE=$(kubectl get AutomationUIConfig -n $NAMESPACE --no-headers -o custom-columns=":metadata.name")
IAF_STORAGE=$(kubectl get AutomationUIConfig -n $NAMESPACE -o jsonpath='{ .items[*].spec.storage.class }')
kubectl delete -n $NAMESPACE AutomationUIConfig $AUTO_UI_INSTANCE

cat <<EOF | kubectl apply -f -
apiVersion: core.automation.ibm.com/v1beta1
kind: AutomationUIConfig
metadata:
  name: $AUTO_UI_INSTANCE
  namespace: $NAMESPACE
spec:
  description: AutomationUIConfig for cp4waiops
  license:
    accept: true
  version: v1.0
  storage:
    class: $IAF_STORAGE
  tls:
    caSecret:
      key: ca.crt
      secretName: external-tls-secret
    certificateSecret:
      secretName: external-tls-secret
EOF


ingress_pod=$(kubectl get secrets -n openshift-ingress | grep tls | grep -v router-metrics-certs-default | awk '{print $1}')
kubectl get secret -n openshift-ingress -o 'go-template={{index .data "tls.crt"}}' ${ingress_pod} | base64 -d > cert.crt
kubectl get secret -n openshift-ingress -o 'go-template={{index .data "tls.key"}}' ${ingress_pod} | base64 -d > cert.key

# Backup secret
kubectl get secret -n $NAMESPACE external-tls-secret -o yaml > external-tls-secret.yaml

# Delete existing
kubectl delete secret -n $NAMESPACE external-tls-secret

# Create the new secret with the AI Manager ingress certificate.
kubectl create secret generic -n $NAMESPACE external-tls-secret --from-file=cert.crt=cert.crt --from-file=cert.key=cert.key --dry-run=client -o yaml | kubectl apply -f -

REPLICAS=$(kubectl get pods -l component=ibm-nginx -o jsonpath='{ .items[*].metadata.name }' | wc -w)
kubectl scale Deployment/ibm-nginx --replicas=0

sleep 3
kubectl scale Deployment/ibm-nginx --replicas=${REPLICAS}