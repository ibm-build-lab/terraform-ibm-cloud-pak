#!/bin/bash
NAMESPACE=$1
oc -n $NAMESPACE extract secret/ibm-nginx-internal-tls-ca --keys=cert.crt --to=/tmp > /dev/null
oc -n $NAMESPACE delete route cpd
oc -n $NAMESPACE create route reencrypt cpd --service=ibm-nginx-svc --port=ibm-nginx-https-port --dest-ca-cert=/tmp/cert.crt
rm /tmp/cert.crt
