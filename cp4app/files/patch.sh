#!/bin/bash

echo "Patching code to get the Tekton Dashboard route"
sed -i.back 's/oc get route tekton-dashboard/oc get route tekton-dashboard -n tekton-pipelines/' /installer/playbook/roles/tekton/tasks/install.yaml

echo "Patching code to get the Application Navigator UI route"
sed -i.back 's/oc get route kappnav-ui-service/oc get route kappnav-ui-service -n kappnav/' /installer/playbook/roles/appnav/tasks/install.yaml
