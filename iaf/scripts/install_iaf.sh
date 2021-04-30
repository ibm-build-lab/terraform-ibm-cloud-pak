#!/bin/sh

echo "Creating namespace ${IAF_NAMESPACE}"
kubectl create namespace ${IAF_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -
kubectl config set-context --current --namespace=${IAF_NAMESPACE}

# Create the Operator catalog source
echo "Creating Catalog Sources..."

kubectl apply -f -<<EOF
${IAF_CATALOGSOURCE_CONTENT}
EOF

sleep 60

echo "Installing Operator..."
kubectl apply -f -<<EOF
${IAF_SUBSCRIPTION_CONTENT}
EOF

sleep 180
