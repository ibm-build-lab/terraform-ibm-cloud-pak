#!/bin/bash
NAMESPACE="cp4d"
set -e

ssltmpdir=${HOME}/tmp/genssl

genSelfSignedCert()
{

    echo "=== generating self signed cert in ${ssltmpdir} ==="

	mkdir -p ${ssltmpdir}


svr_conf=$(cat << EOF
[req]
default_bits=2048
prompt=no
default_md=sha
distinguished_name=dn
req_extensions = v3_req
[dn]
C=YY
ST=XX
L=Home-Town
O=Data and AI
OU=For-CPD
emailAddress=dummy@example.dum
CN=Dummy-Self-signed-Cert
[v3_req]
subjectAltName = @alt_names
extendedKeyUsage = 1.3.6.1.5.5.7.3.1
[alt_names]
DNS.1 = internal-nginx-svc
DNS.2 = *.svc.cluster.lkubectlal
DNS.3 = api-svc
DNS.4 = *.api
DNS.5 = ibm-nginx-svc
DNS.6 = zen-core-api
EOF
)

echo "${svr_conf}" >  ${ssltmpdir}/server.csr.cnf


openssl req -x509 -passin pass:dataPlatf0rm -sha512 -newkey rsa:2048 -keyout ${ssltmpdir}/cert.key -out ${ssltmpdir}/cert.crt -days 2048 -nodes -config ${ssltmpdir}/server.csr.cnf  -extensions v3_req

}

create_external_secret()
{
    echo "=== creating secret ==="
    kubectl create secret generic external-tls-secret --from-file=cert.crt=${ssltmpdir}/cert.crt --from-file=cert.key=${ssltmpdir}/cert.key -n $NAMESPACE --dry-run=client -o yaml | kubectl apply -n $NAMESPACE -f  -
}

nginx_reload()
{
    echo "=== nginx reload ... wait a minute for the secret to be (re-)mounted ==="
    sleep 60s 
    
    for i in `kubectl get pods -n $NAMESPACE | grep ibm-nginx |  cut -f1 -d\ `; do kubectl -n $NAMESPACE exec ${i} -- /scripts/reload.sh; done
}

restart_nginx_pods()
{
    echo "=== restarting nginix pods ==="
    for i in `kubectl get pods -n $NAMESPACE | grep ibm-nginx |  cut -f1 -d\ `; do kubectl -n $NAMESPACE delete po  ${i}; done
}

recreate_route()
{
    echo "=== recreating route ==="
    kubectl delete route ${NAMESPACE}-cpd -n $NAMESPACE
    # NOTE: must us `oc` as `kubectl` does not contain an option to create a route.
    # TODO: Create route template and populate variables.
    oc create route reencrypt ${NAMESPACE}-cpd --service=ibm-nginx-svc --port=ibm-nginx-https-port --dest-ca-cert=${HOME}/tmp/genssl/cert.crt -n $NAMESPACE 
}

genSelfSignedCert
create_external_secret
nginx_reload
restart_nginx_pods
recreate_route
