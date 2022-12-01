
eval "$(jq -r '@sh "export KUBECONFIG=\(.kubeconfig) CP4BA_PROJECT_NAME=\(.cp4ba_project_name)"')"

echo "*********************************************************************************"
echo "******************** Uninstalling CP4BA from the Cluster ... **********************"
echo "*********************************************************************************"


echo
echo

echo "Setting project ${CP4BA_PROJECT_NAME} ..."
kubectl get ns "${CP4BA_PROJECT_NAME}"
echo

kubectl get zen-metastoredb -n "${CP4BA_PROJECT_NAME}" | awk '{print $1}'
echo


for resource in subscription deployments deploymentconfigs configmaps OperatorGroup statefulset EventStreams csv scc jobs pods secrets services roles rolebindings pvc pv namespaces ;
do
  echo " => Deleting the ${resource} ...";
  resources=$(kubectl get "${resource}" -n "${CP4BA_PROJECT_NAME}" | grep cp4ba | awk '{print $1}'); # '
  eval "elements=($resources)"
  for element in "${elements[@]}"; do
      check_resource=true
      while ( $check_resource )
      do
        cmd=$(kubectl delete "${resource}"/"${element}" -n "${CP4BA_PROJECT_NAME}")
        sleep 10
        get_resource=$(kubectl get "${resource}" -n "${CP4BA_PROJECT_NAME}" | grep cp4ba | awk '{print $1}')
        if [ "${get_resource}" == "${resource}" ]
        then
          continue
        elif [ "${get_resource}" == "NotFound" ]; then
          check_resource=false
          break
        else
          check_resource=false
          break
        fi
      done
  done
  echo "******************************************************************************************************************"
done

echo
echo
echo "*********************************************************************************"
echo "**************** Uninstallation of CP4BA completed successfully!!! ****************"
echo "*********************************************************************************"